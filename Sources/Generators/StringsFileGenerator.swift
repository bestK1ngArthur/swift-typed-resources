//
//  StringsFileGenerator.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import SwiftTypedResourcesModels

public struct ResourceStringsFileGenerator {

    public typealias FileContent = String

    public init() {}

    public func generateFileContent(for resources: StringsResources) -> FileContent {
        let markMode: MarkMode = resources.count > 1 ? .byFile : .byKeyDelimeter

        var fileContent = formattedHeader(fileName: fileName, date: Date())
        for resource in resources {
            fileContent += generateFileContent(for: resource, markMode: markMode)
        }
        return fileContent
    }

    private func generateFileContent(for resource: StringsResource, markMode: MarkMode) -> FileContent {
//        resource.strings.strings.map { <#(key: String, value: LocalizableStrings.LocalizableString)#> in
//            <#code#>
//        }
        fatalError()
    }

    private func generateFileContent(for groupedValues: GroupedValues) -> FileContent {
        var fileContent = ""
        if let valuesWithoutGroups = groupedValues[nil], !valuesWithoutGroups.isEmpty {
            for value in valuesWithoutGroups {
                fileContent += formattedValue(name: value.name, value: value.key)
            }
        }

        let groupNames = groupedValues.keys
            .compactMap { $0 }
            .sorted()
        for groupName in groupNames {
            if let groupValues = groupedValues[groupName], !groupName.isEmpty {
                fileContent += newLine
                fileContent += formattedMark(name: groupName)

                for value in groupValues {
                    fileContent += formattedValue(name: value.name, value: value.key)
                }
            }
        }
    }
}

private extension ResourceStringsFileGenerator {

    enum MarkMode {
        case byFile
        case byKeyDelimeter
    }

    typealias GroupedValues = [String?: [(name: String, key: String)]]
}

fileprivate let newLine = "\n"
fileprivate let intent = String(repeating: " ", count: 4)

fileprivate func intents(count: Int) -> String {
    return .init(repeating: intent, count: count)
}

fileprivate let fileName = "Strings"

fileprivate func formattedHeader(fileName: String, date: Date) -> String {
"""
//
//  \(fileName).generated.swift
//  swift-typed-resources
//
//  Generated on \(date.formatted(date: .numeric, time: .omitted)).
//
"""
}

fileprivate func formattedExtension(name: String, content: String) -> String {
"""
public extension \(name) {
\(content)
}
"""
}

fileprivate func formattedMark(name: String) -> String {
"""
// MARK: \(name)
"""
}

fileprivate func formattedValue(name: String, value: String) -> String {
"""
\(intent)let \(name) = \(value)
"""
}

/*
        guard !strings.isEmpty else { return nil }

        let stringsWithoutArguments = strings.filter(\.values.isEmpty)
        let stringsWithoutArgumentsTables = getTables(for: stringsWithoutArguments)

        let stringsWithArguments = strings.filter { !$0.values.isEmpty }
        let stringsWithArgumentsTables = getTables(for: stringsWithArguments)

        return formattedFile(
            stringsValue: generateStringsValue(
                from: stringsWithoutArguments,
                tables: stringsWithoutArgumentsTables
            ),
            stringsWithArgumentsValue: generateStringsValue(
                from: stringsWithArguments,
                tables: stringsWithArgumentsTables
            )
        )
    }

    // MARK: Private

    private func getTables(for strings: ResourceStrings) -> [String?] {
        var tablesSet: Set<String> = .init()
        strings.forEach { string in
            tablesSet.insert(string.table)
        }
        let tables = Array(tablesSet).sorted()
        return [nil] + tables
    }

    private func formattedHeader(date: Date) -> String {
        """
        //
        //  Strings.generated.swift
        //  GenerateResources
        //
        //  Generated on \(date.formatted(date: .numeric, time: .omitted)).
        //
        """
    }

    private func formattedFile(
        stringsValue: String,
        stringsWithArgumentsValue: String
    ) -> String {
        """
        \(formattedHeader(date: .init()))

        import Foundation

        public struct Strings {

            static let shared = Self()
        \(String.newLine)\(stringsValue)
        }

        // MARK: -

        public struct StringsWithArguments {

            static let shared = Self()
        \(String.newLine)\(stringsWithArgumentsValue)
        }\(String.newLine)
        """
    }

    private func generateStringsValue(from strings: ResourceStrings, tables: [String?]) -> String {
        return tables.reduce("") { result, table in
            let tableStrings = strings.filter { $0.table == table }
            return result + generateStringsValue(from: tableStrings, table: table)
        }
        .removingBoundNewLines()
    }

    private func generateStringsValue(from strings: ResourceStrings, table: String?) -> String {
        let graphElements = strings
            .filter { $0.table == table }
            .map { GraphElement(string: $0, path: $0.keyPath) }

        let stringsValue = generateNestedValues(
            graphElements: graphElements,
            intent: 1
        )

        if let table {
            return
                """
                \(String.intents(count: 1))// MARK: - \(table)\(String.newLine)
                \(stringsValue)\(String.newLine)
                """
        } else {
            return
                "\(stringsValue)\(String.newLine)"
        }
    }

    private func generateNestedValues(
        graphElements: [GraphElement],
        intent: Int
    ) -> String {
        let graphElementsToVars = graphElements
            .filter { $0.path.count == 1 }
            .sorted { $0.string.key < $1.string.key }

        let varsValue = graphElementsToVars.reduce("") { result, graphElement in
            guard let formattedString = getFormattedString(for: graphElement, intent: intent) else {
                return result
            }

            return result + formattedString
        }

        let value = varsValue.removingBoundNewLines()
        return value + String.newLine
    }

    private func getFormattedString(for graphElement: GraphElement, intent: Int) -> String? {
        guard let name = graphElement.path.last else {
            return nil
        }

        let formattedString = getFormattedString(graphElement.string, name: name, intent: intent)
        return "\(formattedString)\(String.newLine)"
    }

    private func getFormattedString(_ string: ResourceString, name: String, intent: Int) -> String {
        let varName = "\(string.table.firstCharacterLowercased())\(string.key.firstCharacterUppercased())"
        return """
        \(String.intents(count: intent))public let \(varName) = "\(string.localizationKey)"
        """
    }
}

private extension ResourceStringsFileGenerator {

    struct GraphElement {
        let string: ResourceString
        var path: [String]
    }
}

private extension ResourceString {

    var keyPath: [String] {
        key
            .split(separator: ".")
            .map(String.init)
    }
}

// MARK: - Constants

extension String {

    static let newLine = "\n"
    static let intent = "    "

    static func intents(count: Int) -> String {
        return .init(repeating: .intent, count: count)
    }

    func removingBoundNewLines() -> String {
        return trimmingCharacters(in: .newlines)
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
*/
