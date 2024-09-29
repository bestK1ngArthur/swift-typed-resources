//
//  GenerateResources.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation

/*
import PackagePlugin

@main
struct GenerateResources: CommandPlugin {

    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let packagePath = context.package.directory

        try generateStrings(packagePath: packagePath)
        try generateImages(packagePath: packagePath)
    }

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
