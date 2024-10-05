//
//  ImagesFileGenerator.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 02.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

import Foundation
import SwiftTypedResourcesModels

public struct ImagesFileGenerator {

    public typealias FileContent = String

    public init() {}

    public func generateFileContent(
        for resources: ImagesResources,
        fileName: String,
        markMode: MarkMode? = .automatic
    ) -> FileContent {
        var markMode = markMode
        if markMode == .automatic {
            markMode = resources.count > 1 ? .byTable : .byParentFolder
        }

        var fileContent = formattedHeader(fileName: fileName, date: Date())
        fileContent += newLine
        fileContent += newLine
        fileContent += "import SwiftTypedResources"
        fileContent += newLine
        fileContent += newLine
        fileContent += generateExtensionContent(for: resources, markMode: markMode)

        return fileContent
    }

    private func generateExtensionContent(
        for resources: ImagesResources,
        markMode: MarkMode?
    ) -> FileContent {
        let values = getValues(from: resources, markMode: markMode)
        let groupedValues: GroupedValues
        switch markMode {
            case .byTable:
                groupedValues = Dictionary(
                    grouping: values,
                    by: { $0.group?.firstCharacterUppercased() }
                )
                .mapValues { keys in
                    keys
                        .map {
                            let varName = $0.value.varName
                            let name = if let group = $0.group {
                                "\(group.firstCharacterLowercased())\(varName.firstCharacterUppercased())"
                            } else {
                                varName
                            }
                            return (name: name, value: $0.value)
                        }
                        .sorted { $0.name < $1.name }
                }

            case .byParentFolder:
                groupedValues = Dictionary(
                    grouping: values,
                    by: { $0.group?.firstCharacterUppercased() }
                )
                .mapValues { values in
                    values
                        .map { (name: $0.value.varName, value: $0.value) }
                        .sorted { $0.name < $1.name }
                }

            default:
                let values = values
                    .map { (name: $0.value.varName, value: $0.value) }
                    .sorted { $0.name < $1.name }
                groupedValues = [nil: values]
        }

        let valuesContent = generateValuesContent(for: groupedValues)
        let extensionContent = formattedExtension(name: "TypedImages", content: valuesContent)

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
                content += generateValue(value)

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
                    content += generateValue(value)
                }

                if index < groupNames.count - 1 {
                    content += newLine
                }
            }
        }

        return content
    }

    // MARK: Values

    private func getValues(from resources: ImagesResources, markMode: MarkMode?) -> Values {
        var values: Values = []
        for resource in resources {
            for (_, asset) in resource.assets {
                let group: String? = switch markMode {
                    case .byTable:
                        resource.table
                    case .byParentFolder:
                        if case .folder(let folder) = asset {
                            folder.name
                        } else {
                            nil
                        }

                    default:
                        nil
                }

                switch asset {
                    case .folder(let folder):
                        values += getValues(from: folder, group: group)
                    case .imageAsset(let imageAsset):
                        values.append((group: group, value: imageAsset.fileName))
                }
            }
        }
        return values
    }

    private func getValues(from folder: ImagesResource.Folder, group: String?) -> Values {
        var values: Values = []
        for (_, asset) in folder.assets {
            switch asset {
                case .folder(let folder):
                    values += getValues(from: folder, group: group)
                case .imageAsset(let imageAsset):
                    values.append((group: group, value: imageAsset.fileName))
            }
        }
        return values
    }

    private func generateValue(_ value: GroupedValue) -> FileContent {
        formattedValue(
            name: value.name,
            type: "TypedImageConfig",
            value: "(name: \"\(value.value)\", bundle: .module)"
        )
    }
}

extension ImagesFileGenerator {

    public enum MarkMode {
        case byTable
        case byParentFolder
        case automatic
    }

    private typealias Values = [(group: String?, value: String)]
    private typealias GroupedValue = (name: String, value: String)
    private typealias GroupedValues = [String?: [GroupedValue]]
}
