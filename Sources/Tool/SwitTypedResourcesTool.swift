//
//  SwiftTypedResourcesTool.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 05.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import ArgumentParser
import Foundation
import SwiftTypedResourcesGenerators
import SwiftTypedResourcesModels
import SwiftTypedResourcesParsers

@main
struct SwiftTypedResourcesTool: ParsableCommand {

    enum Resource: String, ExpressibleByArgument {
        case images
        case strings
    }

    @Argument(help: "Specify the resources path")
    public var resourcesPath: String

    @Argument(help: "Specify the sources path")
    public var sourcesPath: String

    @Option(help: "Specify the resources to generate", transform: Self.parseResources(_:))
    public var resources: Set<Resource> = [.images, .strings]

    @Option(help: "Specify the bundle")
    public var bundle: String = "main"

    public func run() throws {
        let inputPath = URL(fileURLWithPath: resourcesPath)
        let outputPath = URL(fileURLWithPath: sourcesPath).appendingPathComponent("Generated")

        if !outputPath.hasDirectoryPath {
            print("Folder created")
            try Self.fileManager.createDirectory(
                at: outputPath,
                withIntermediateDirectories: false
            )
        }

        guard let bundle = ResourceBundle(rawValue: bundle) else {
            print("Invalid bundle name")
            return
        }

        if resources.contains(.strings) {
            try Self.generateStrings(from: inputPath, to: outputPath, bundle: bundle)
        }

        if resources.contains(.images) {
            try Self.generateImages(from: inputPath, to: outputPath, bundle: bundle)
        }
    }

    // MARK: Private

    private static let fileManager: FileManager = .default
    private static let encoding: String.Encoding = .utf8

    private static func generateStrings(from inputPath: URL, to outputPath: URL, bundle: ResourceBundle) throws {
        let fileURLs = findFiles(withExtension: "xcstrings", at: inputPath)

        guard !fileURLs.isEmpty else {
            print("No string resource files found")
            return
        }

        let parser = XCStringsParser()
        let resources: StringsResources = fileURLs.compactMap { fileURL in
            guard
                let data = try? Data(contentsOf: fileURL),
                let strings = try? parser.parse(data, encoding: encoding)
            else {
                return nil
            }

            return .init(
                table: fileURL.deletingPathExtension().lastPathComponent,
                strings: strings,
                bundle: bundle
            )
        }

        let generator = StringsFileGenerator()
        let fileName = "TypedStrings.swift"
        let fileContent = generator.generateFileContent(for: resources, fileName: fileName)
        let fileURL = outputPath.appending(fileName)
        try fileContent.write(
            to: fileURL,
            atomically: true,
            encoding: encoding
        )
    }

    private static func generateImages(from inputPath: URL, to outputPath: URL, bundle: ResourceBundle) throws {
        let fileURLs = findFiles(withExtension: "xcassets", at: inputPath)

        guard !fileURLs.isEmpty else {
            print("No image resource files found")
            return
        }

        let parser = XCAssetsParser(fileManager: fileManager)
        let resources: ImagesResources = fileURLs.compactMap { fileURL in
            try? parser.parse(at: fileURL, bundle: bundle)
        }

        let generator = ImagesFileGenerator()
        let fileName = "TypedImages.swift"
        let fileContent = generator.generateFileContent(for: resources, fileName: fileName)
        let fileURL = outputPath.appending(fileName)
        try fileContent.write(
            to: fileURL,
            atomically: true,
            encoding: encoding
        )
    }

    private static func findFiles(withExtension fileExtension: String, at path: URL) -> [URL] {
        do {
            var results: [URL] = []
            let items = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: [])
            for item in items {
                if item.pathExtension == fileExtension {
                    results.append(item)
                } else if item.hasDirectoryPath {
                    let subResults = findFiles(withExtension: fileExtension, at: item)
                    results.append(contentsOf: subResults)
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
