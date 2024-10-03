//
//  ImagesResource.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

public typealias ImagesResources = [ImagesResource]

public struct ImagesResource: Equatable {

    public enum Asset: Equatable {
        case folder(Folder)
        case imageAsset(ImageAsset)
    }

    public struct Folder: Equatable {
        public let name: String
        public let assets: [String: Asset]
    }

    public struct ImageAsset: Equatable {
        public let fileName: String
    }

    public let table: String
    public let assets: [String: Asset]

    public init(table: String, assets: [String: Asset]) {
        self.table = table
        self.assets = assets
    }
}
