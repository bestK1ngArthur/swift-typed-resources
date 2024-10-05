//
//  GenerateResourcesCommand.swift.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import PackagePlugin

@main
struct GenerateResourcesCommand: CommandPlugin {

    private let fileManager: FileManager = .default

    func performCommand(context: PluginContext, arguments: [String]) async throws {

        let tool = try context.tool(named: "SwiftTypedResourcesTool")

        let packagePath = URL(fileURLWithPath: context.pluginWorkDirectory.string)

        try generateStrings(packagePath: packagePath)
        //        try generateImages(packagePath: packagePath)
    }

    private func generateStrings(packagePath: URL) throws {
        let fileURLs = findFiles(withExtension: "xcstrings", at: packagePath)
        guard !fileURLs.isEmpty else { return }

//        let stringsParser = XCAs
//        for fileURL in fileURLs {
//
//        }
    }

    private func findFiles(withExtension fileExtension: String, at path: URL) -> [URL] {
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


}


/*
    // MARK: Sources

    private let sourcesPath = "Sources"

    // MARK: Parsers

    private let stringsParser = ResourceStringsParser()
    private let imagesParser = ResourceImagesParser()

    // MARK: Generators

    private let stringsFileGenerator = ResourceStringsFileGenerator()
    private let imagesFileGenerator = ResourceImagesFileGenerator()
}

// MARK: Strings

private extension GenerateResources {

    var stringsResourcesPath: String { "\(sourcesPath)/Resources" }
    var stringsFilePath: String { "\(sourcesPath)/Generated/Strings.generated.swift" }

    func generateStrings(packagePath: Path) throws {
        let stringsPath = packagePath.appending(subpath: stringsResourcesPath)
        let strings = try stringsParser.parseStrings(from: stringsPath, with: .xcstrings)

        let filePath = packagePath.appending(subpath: stringsFilePath)
        let file = stringsFileGenerator.generateFile(from: strings)
        try file?.write(
            to: .init(fileURLWithPath: filePath.string),
            atomically: true,
            encoding: .utf8
        )
    }
}

// MARK: Images

private extension GenerateResources {

    var imagesResourcesPath: String { "\(sourcesPath)/Resources" }
    var imagesFilePath: String { "\(sourcesPath)/Generated/Images.generated.swift" }

    func generateImages(packagePath: Path) throws {
        let imagesPath = packagePath.appending(subpath: imagesResourcesPath)
        let images = try imagesParser.parseImages(from: imagesPath)

        let filePath = packagePath.appending(subpath: imagesFilePath)
        let file = imagesFileGenerator.generateFile(from: images)
        try file?.write(
            to: .init(fileURLWithPath: filePath.string),
            atomically: true,
            encoding: .utf8
        )
    }
}
*/
