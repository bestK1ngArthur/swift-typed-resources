//
//  Images.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

public struct TypedImages {
    static let shared = Self()
}

public typealias TypedImage = KeyPath<TypedImages, String>
