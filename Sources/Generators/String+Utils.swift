//
//  String+Utils.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation

extension String {

    var varName: String {
        let components = components(separatedBy: delimiters)
        let formattedComponents = components
            .filter { !$0.isEmpty }
            .enumerated()
            .map { index, element in
                index == 0 ? element.firstCharacterLowercased() : element.firstCharacterUppercased()
            }
        return formattedComponents.joined()
    }

    var group: String? {
        let components = components(separatedBy: delimiters)
        if components.count > 1 {
            return components.first { !$0.isEmpty }
        } else {
            return nil
        }
    }

    func firstCharacterLowercased() -> String {
        guard let firstChar = first else {
            return self
        }

        return String(firstChar).lowercased() + dropFirst()
    }

    func firstCharacterUppercased() -> String {
        guard let firstChar = first else {
            return self
        }

        return String(firstChar).uppercased() + dropFirst()
    }
}

let newLine = "\n"
let intent = String(repeating: " ", count: 4)
let delimiters = CharacterSet(charactersIn: ".-_")

func intents(count: Int) -> String {
    .init(repeating: intent, count: count)
}
