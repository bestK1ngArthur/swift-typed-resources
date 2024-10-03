//
//  StringsFileGeneratorTests.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 29.09.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

@testable import SwiftTypedResourcesGenerators

import Foundation
import SwiftTypedResourcesModels
import Testing

@Suite("String's File Generator Tests")
struct StringsFileGeneratorTests {

    @Test
    func generateOneTable() throws {
        let generator = StringsFileGenerator()
        let string = LocalizableStrings.LocalizableString(
            extractionState: .manual,
            localizations: [
                .init(rawValue: "en"): .default(
                    .string(
                        .init(
                            state: .translated,
                            value: ""
                        )
                    )
                )
            ]
        )
        let pluralString = LocalizableStrings.LocalizableString(
            extractionState: .manual,
            localizations: [
                .init(rawValue: "en"): .variated(
                    .byPlural(
                        [
                            .one: .string(
                                .init(
                                    state: .translated,
                                    value: ""
                                )
                            )
                        ]
                    )
                )
            ]
        )
        let resource = StringsResource(
            table: "Strings",
            strings: .init(
                sourceLanguage: .init(rawValue: "en"),
                strings: [
                    "test-One": string,
                    "_test_two": string,
                    "Test.Three": string,
                    "Flex.Two": string,
                    "base2": string,
                    "base": string,
                    "PluralOne": pluralString
                ]
            )
        )
        let expected = """
        //
        //  Strings.generated.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        public extension TypedStrings {

            public let base = "base"
            public let base2 = "base2"

            // MARK: Flex
            public let flexTwo = "Flex.Two"

            // MARK: Test
            public let testThree = "Test.Three"
            public let testTwo = "_test_two"
            public let testOne = "test-One"
        }
        
        public extension TypedStringsWithArguments {

            public let pluralOne = "PluralOne"
        }
        """
        let real = generator.generateFileContent(for: [resource])
        #expect(expected == real)
    }

    @Test
    func generateFewTables() throws {
        let generator = StringsFileGenerator()
        let string = LocalizableStrings.LocalizableString(
            extractionState: .manual,
            localizations: [
                .init(rawValue: "en"): .default(
                    .string(
                        .init(
                            state: .translated,
                            value: ""
                        )
                    )
                )
            ]
        )
        let pluralString = LocalizableStrings.LocalizableString(
            extractionState: .manual,
            localizations: [
                .init(rawValue: "en"): .variated(
                    .byPlural(
                        [
                            .one: .string(
                                .init(
                                    state: .translated,
                                    value: ""
                                )
                            )
                        ]
                    )
                )
            ]
        )
        let resources: StringsResources = [
            .init(
                table: "First",
                strings: .init(
                    sourceLanguage: .init(rawValue: "en"),
                    strings: [
                        "DefaultOne": string,
                        "DefaultTwo": string,
                        "PluralOne": pluralString
                    ]
                )
            ),
            .init(
                table: "Second",
                strings: .init(
                    sourceLanguage: .init(rawValue: "en"),
                    strings: [
                        "DefaultOne": string,
                        "DefaultTwo": string,
                        "PluralOne": pluralString
                    ]
                )
            )
        ]

        let expected = """
        //
        //  Strings.generated.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        public extension TypedStrings {

            // MARK: First
            public let firstDefaultOne = "DefaultOne"
            public let firstDefaultTwo = "DefaultTwo"

            // MARK: Second
            public let secondDefaultOne = "DefaultOne"
            public let secondDefaultTwo = "DefaultTwo"
        }
        
        public extension TypedStringsWithArguments {

            // MARK: First
            public let firstPluralOne = "PluralOne"
        
            // MARK: Second
            public let secondPluralOne = "PluralOne"
        }
        """
        let real = generator.generateFileContent(for: resources)
        #expect(expected == real)
    }

    // TODO: Add tests for different mark modes
}
