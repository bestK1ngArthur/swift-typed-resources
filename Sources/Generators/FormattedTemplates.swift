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
//  \(fileName).generated.swift
//  swift-typed-resources
//
//  Generated on \(date.formatted(date: .numeric, time: .omitted)).
//
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

func formattedValue(name: String, value: String) -> String {
"""
\(intent)public let \(name) = \"\(value)\"
"""
}
