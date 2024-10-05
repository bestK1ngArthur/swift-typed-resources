//
//  StringsFileGenerator.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import SwiftTypedResourcesModels

public struct StringsFileGenerator {

    public typealias FileContent = String

    public init() {}

    public func generateFileContent(
        for resources: StringsResources,
        fileName: String,
        markMode: MarkMode? = .automatic
    ) -> FileContent {
        var markMode = markMode
        if markMode == .automatic {
            markMode = resources.count > 1 ? .byTable : .byKeyDelimeter
        }

        var fileContent = formattedHeader(fileName: fileName, date: Date())
        fileContent += newLine
        fileContent += newLine
        fileContent += "import SwiftTypedResources"
        fileContent += newLine
        fileContent += generateMainContent(for: resources, markMode: markMode)

        return fileContent
    }

    private func generateMainContent(
        for resources: StringsResources,
        markMode: MarkMode?
    ) -> FileContent {
        var stringsKeys: [(key: String, table: String)] = []
        var stringsWithArgumentsKeys: [(key: String, table: String)] = []

        for resource in resources {
            for (key, string) in resource.strings.strings {
                guard let localization = string.localizations.first?.value else {
                    continue
                }

                if localization.containesNestedValue {
                    stringsWithArgumentsKeys.append((key, resource.table))
                } else {
                    stringsKeys.append((key, resource.table))
                }
            }
        }

        var fileContent = ""
        if !stringsKeys.isEmpty {
            fileContent += newLine
            fileContent += generateExtensionContent(
                for: stringsKeys,
                extensionName: "TypedStrings",
                markMode: markMode
            )
        }

        if !stringsKeys.isEmpty, !stringsWithArgumentsKeys.isEmpty {
            fileContent += newLine
        }

        if !stringsWithArgumentsKeys.isEmpty {
            fileContent += newLine
            fileContent += generateExtensionContent(
                for: stringsWithArgumentsKeys,
                extensionName: "TypedStringsWithArguments",
                markMode: markMode
            )
        }

        return fileContent
    }

    private func generateExtensionContent(
        for keys: [(key: String, table: String)],
        extensionName: String,
        markMode: MarkMode?
    ) -> FileContent {
        let groupedValues: GroupedValues
        switch markMode {
            case .byTable:
                groupedValues = Dictionary(
                    grouping: keys,
                    by: { $0.table.firstCharacterUppercased() }
                )
                .mapValues { keys in
                    keys
                        .map { (name: "\($0.table.firstCharacterLowercased())\($0.key.varName.firstCharacterUppercased())", key: $0.key) }
                        .sorted { $0.name < $1.name }
                }

            case .byKeyDelimeter:
                let keys = keys.map(\.key)
                groupedValues = Dictionary(
                    grouping: keys,
                    by: { $0.group?.firstCharacterUppercased() }
                )
                .mapValues { keys in
                    keys
                        .map { (name: $0.varName, key: $0) }
                        .sorted { $0.name < $1.name }
                }

            default:
                let keys = keys
                    .map { (name: $0.key.varName, key: $0.key) }
                    .sorted { $0.name < $1.name }
                groupedValues = [nil: keys]
        }

        let valuesContent = generateValuesContent(for: groupedValues)
        let extensionContent = formattedExtension(name: extensionName, content: valuesContent)
        return extensionContent
    }

    private func generateValuesContent(for groupedValues: GroupedValues) -> FileContent {
        var content = ""

        let groupNames = groupedValues.keys
            .compactMap { $0 }
            .sorted()

        if let valuesWithoutGroups = groupedValues[nil], !valuesWithoutGroups.isEmpty {
            for value in valuesWithoutGroups {
                content += newLine
                content += formattedValue(name: value.name, value: value.key)
            }

            if !groupNames.isEmpty {
                content += newLine
            }
        }

        for (index, groupName) in groupNames.enumerated() {
            if let groupValues = groupedValues[groupName], !groupName.isEmpty {
                content += newLine
                content += formattedMark(name: groupName)

                for value in groupValues {
                    content += newLine
                    content += formattedValue(name: value.name, value: value.key)
                }

                if index < groupNames.count - 1 {
                    content += newLine
                }
            }
        }

        return content
    }
}

extension StringsFileGenerator {

    public enum MarkMode {
        case byTable
        case byKeyDelimeter
        case automatic
    }

    private typealias GroupedValues = [String?: [(name: String, key: String)]]
}

private extension LocalizableStrings.LocalizableString.Localization {

    var containesNestedValue: Bool {
        switch self {
            case let .default(unit):
                unit.containsNestedValue

            case let .variated(.byDevice(variations)):
                variations.values.contains(where: \.containsNestedValue)

            case let .variated(.byPlural(variations)):
                variations.values.contains(where: \.containsNestedValue)
        }
    }
}

private extension LocalizableStrings.LocalizableString.Localization.Unit {

    var containsNestedValue: Bool {
        switch self {
            case let .string(stringUnit):
                stringUnit.containsNestedValue
        }
    }
}

private extension LocalizableStrings.LocalizableString.Localization.StringUnit {

    private enum NestedValue: String, CaseIterable {
        case string = "%@"
        case double = "%d"
        case int = "%i"
    }

    var containsNestedValue: Bool {
        NestedValue.allCases.contains(where: { value.contains($0.rawValue) })
    }
}
