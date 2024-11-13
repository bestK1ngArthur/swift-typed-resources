//
//  FormattedTemplates.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 02.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation

func formattedHeader(fileName: String, date: Date) -> String {
"""
//
//  \(fileName)
//  This file was automatically generated and should not be edited.
//
"""
}

func formattedImports(library: String = "SwiftTypedResources") -> String {
"""
import \(library)
"""
}

func formattedExtension(name: String, content: String) -> String {
"""
public extension \(name) {
\(content)
}
"""
}

func formattedMark(name: String) -> String {
"""
\(intent)// MARK: \(name)
"""
}

func formattedValue(name: String, type: String, value: String) -> String {
"""
\(intent)var \(name): \(type) { \(value) }
"""
}
