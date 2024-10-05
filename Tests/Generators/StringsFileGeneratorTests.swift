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

    private let generator = StringsFileGenerator()

    @Test
    func generate_oneTable() throws {
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
        //  TypedStrings.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        import SwiftTypedResources
        
        public extension TypedStrings {

            var base: String { "base" }
            var base2: String { "base2" }

            // MARK: Flex
            var flexTwo: String { "Flex.Two" }

            // MARK: Test
            var testOne: String { "test-One" }
            var testThree: String { "Test.Three" }
            var testTwo: String { "_test_two" }
        }
        
        public extension TypedStringsWithArguments {

            var pluralOne: String { "PluralOne" }
        }
        """
        let real = generator.generateFileContent(
            for: [resource],
            fileName: "TypedStrings.swift"
        )
        #expect(expected == real)
    }

    @Test
    func generate_fewTables() throws {
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
        //  TypedStrings.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        import SwiftTypedResources
        
        public extension TypedStrings {

            // MARK: First
            var firstDefaultOne: String { "DefaultOne" }
            var firstDefaultTwo: String { "DefaultTwo" }

            // MARK: Second
            var secondDefaultOne: String { "DefaultOne" }
            var secondDefaultTwo: String { "DefaultTwo" }
        }
        
        public extension TypedStringsWithArguments {

            // MARK: First
            var firstPluralOne: String { "PluralOne" }
        
            // MARK: Second
            var secondPluralOne: String { "PluralOne" }
        }
        """
        let real = generator.generateFileContent(
            for: resources,
            fileName: "TypedStrings.swift"
        )
        #expect(expected == real)
    }
}
