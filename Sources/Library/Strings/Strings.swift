//
//  Strings.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation

public struct TypedStrings {
    static let shared = Self()
}

public struct TypedStringsWithArguments {
    static let shared = Self()
}

public typealias TypedString = KeyPath<TypedStrings, TypedStringConfig>
public typealias TypedStringWithArguments = KeyPath<TypedStringsWithArguments, TypedStringConfig>
public typealias TypedStringConfig = (key: String, table: String, bundle: Bundle)
