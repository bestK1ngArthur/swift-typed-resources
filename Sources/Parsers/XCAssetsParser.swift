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
public struct XCAssetsParser {

    private let fileManager: FileManager

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    public func parse(at url: URL, bundle: ResourceBundle) throws -> ImagesResource {
        let assets = try parseAssets(at: url)
        return .init(
            table: url.lastPathComponent,
            assets: assets,
            bundle: bundle
        )
    }

    private func parseAssets(at url: URL) throws -> [String: ImagesResource.Asset] {
        var assets: [String: ImagesResource.Asset] = [:]

        let assetKeys = try fileManager.contentsOfDirectory(atPath: url.path)
        for assetKey in assetKeys {
            let assetURL = url.appending(assetKey)

            guard checkFolder(at: assetURL) else {
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

    public enum ParserError: Error {
        case unsupportedAssetType
    }
}

public extension URL {

    func appending(_ component: String) -> Self {
        if #available(iOS 16.0, *) {
            appending(component: component)
        } else {
            URL(fileURLWithPath: "\(path)/\(component)")
        }
    }
}
