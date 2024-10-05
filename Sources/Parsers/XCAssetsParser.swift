//
//  XCAssetsParser.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 05.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import SwiftTypedResourcesModels

// TODO: Add tests
struct XCAssetsParser {

    private let fileManager: FileManager

    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    func parse(at url: URL) throws -> ImagesResource {
        let assets = try parseAssets(at: url)
        return .init(
            table: url.lastPathComponent,
            assets: assets
        )
    }

    private func parseAssets(at url: URL) throws -> [String: ImagesResource.Asset] {
        var assets: [String: ImagesResource.Asset] = [:]

        let assetKeys = try fileManager.contentsOfDirectory(atPath: url.path)
        for assetKey in assetKeys {
            let assetURL = if #available(iOS 16.0, *) {
                url.appending(component: assetKey)
            } else {
                URL(string: "\(url)/\(assetKey)")
            }

            guard let assetURL, checkFolder(at: assetURL) else {
                continue
            }

            let asset = try parseAsset(at: assetURL)
            assets[assetKey] = asset
        }

        return assets
    }

    private func parseAsset(at url: URL) throws -> ImagesResource.Asset {
        switch url.pathExtension {
            case "imageset":
                let fileName = url.deletingPathExtension().lastPathComponent
                return .imageAsset(.init(fileName: fileName))

            case "":
                let name = url.lastPathComponent
                let assets = try parseAssets(at: url)
                return .folder(.init(name: name, assets: assets))

            default:
                throw ParserError.unsupportedAssetType
        }
    }

    private func checkFolder(at url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
}

extension XCAssetsParser {

    enum ParserError: Error {
        case unsupportedAssetType
    }
}
