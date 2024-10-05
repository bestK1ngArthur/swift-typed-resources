//
//  SwiftTypedResourcesTool.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 05.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import ArgumentParser
import SwiftTypedResourcesParsers
import SwiftTypedResourcesModels
import SwiftTypedResourcesGenerators

@main
struct SwiftTypedResourcesTool: ParsableCommand {

    enum Resource: String, ExpressibleByArgument {
        case images
        case strings
    }

    @Option(help: "Specify the resources to generate", transform: Self.parseResources(_:))
    public var resources: Set<Resource> = [.images, .strings]

    @Argument(help: "Specify the resources path")
    public var path: String

    public func run() throws {
        guard let inputPath = URL(string: path) else {
            throw ArgumentParser.ValidationError("Invalid path")
        }

        let outputPath = inputPath.appendingPathComponent("Generated")
        if !Self.folderExists(at: outputPath) {
            try Self.fileManager.createDirectory(
                at: outputPath,
                withIntermediateDirectories: false
            )
        }

        try Self.generateStrings(from: inputPath, to: outputPath)

        print("Path is \(path)")
        resources.forEach { resource in
            print("Generate \(resource.rawValue)")
        }
    }

    // MARK: Private

    private static let fileManager: FileManager = .default

    private static func generateStrings(from inputPath: URL, to outputPath: URL) throws {
        let fileURLs = findFiles(withExtension: "xcstrings", at: inputPath)

        guard !fileURLs.isEmpty else { return }

        let parser = XCStringsParser()
        let resources: StringsResources = fileURLs.compactMap { fileURL in
            guard
                let data = try? Data(contentsOf: fileURL),
                let strings = try? parser.parse(data)
            else {
                return nil
            }

            return .init(
                table: fileURL.deletingPathExtension().lastPathComponent,
                strings: strings
            )
        }

        let generator = StringsFileGenerator()
        let fileContent = generator.generateFileContent(for: resources)
        let fileURL = outputPath.appending("TypedStrings.swift")
        try fileContent.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )
    }

    private static func findFiles(withExtension fileExtension: String, at path: URL) -> [URL] {
        do {
            var results: [URL] = []
            let items = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            for item in items {
                if item.hasDirectoryPath {
                    let subResults = findFiles(withExtension: fileExtension, at: item)
                    results.append(contentsOf: subResults)
                } else if item.pathExtension == fileExtension {
                    results.append(item)
                }
            }
            return results
        } catch {
            // FIXME: Throw error
            fatalError("Error reading contents of directory: \(error.localizedDescription)")
        }
    }

    private static func parseResources(_ input: String) throws -> Set<Resource> {
        let resources = input
            .split(separator: "+")
            .compactMap { Resource.init(rawValue: String($0)) }
        return Set(resources)
    }

    private static func folderExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
