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

    public func generateFileContent(for resources: StringsResources) -> FileContent {
        let markMode: MarkMode = resources.count > 1 ? .byFile : .byKeyDelimeter

        var fileContent = formattedHeader(fileName: fileName, date: Date())
        fileContent += newLine

        for resource in resources {
            fileContent += generateFileContent(for: resource, markMode: markMode)
        }

        return fileContent
    }

    private func generateFileContent(for resource: StringsResource, markMode: MarkMode) -> FileContent {
        var stringsKeys: [String] = []
        var stringsWithArgumentsKeys: [String] = []

        for (key, string) in resource.strings.strings {
            guard let localization = string.localizations.first?.value else {
                continue
            }

            if case .variated(.byPlural) = localization {
                stringsWithArgumentsKeys.append(key)
            } else {
                stringsKeys.append(key)
            }
        }

        var fileContent = ""
        if !stringsKeys.isEmpty {
            fileContent += newLine
            fileContent += generateExtensionContent(
                for: stringsKeys,
                fileName: resource.table,
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
                fileName: resource.table,
                extensionName: "TypedStringsWithArguments",
                markMode: markMode
            )
        }

        return fileContent
    }

    private func generateExtensionContent(
        for keys: [String],
        fileName: String,
        extensionName: String,
        markMode: MarkMode
    ) -> FileContent {
        let groupedValues: GroupedValues
        switch markMode {
            case .byFile:
                let sortedValues = keys
                    .sorted()
                    .map { (name: "\(fileName.firstCharacterLowercased())\($0.varName.firstCharacterUppercased())", key: $0) }
                groupedValues = [fileName.capitalized: sortedValues]

            case .byKeyDelimeter:
                groupedValues = Dictionary(grouping: keys, by: { $0.group?.capitalized }).mapValues { keys in
                    keys
                        .sorted()
                        .map { (name: $0.varName, key: $0) }
                }
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

private extension StringsFileGenerator {

    enum MarkMode {
        case byFile
        case byKeyDelimeter
    }

    typealias GroupedValues = [String?: [(name: String, key: String)]]
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
\(intent)// MARK: \(name)
"""
}

fileprivate func formattedValue(name: String, value: String) -> String {
"""
\(intent)public let \(name) = \"\(value)\"
"""
}
