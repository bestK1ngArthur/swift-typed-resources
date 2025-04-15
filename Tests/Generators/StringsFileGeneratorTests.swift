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
                                    value: "test %@"
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
            ),
            bundle: .module
        )
        let expected = """
        //
        //  TypedStrings.swift
        //  This file was automatically generated and should not be edited.
        //

        import SwiftTypedResources
        
        public extension TypedStrings {

            var base: TypedStringConfig { (key: "base", table: "Strings", bundle: .module) }
            var base2: TypedStringConfig { (key: "base2", table: "Strings", bundle: .module) }

            // MARK: Flex
            var flexTwo: TypedStringConfig { (key: "Flex.Two", table: "Strings", bundle: .module) }

            // MARK: Test
            var testOne: TypedStringConfig { (key: "test-One", table: "Strings", bundle: .module) }
            var testThree: TypedStringConfig { (key: "Test.Three", table: "Strings", bundle: .module) }
            var testTwo: TypedStringConfig { (key: "_test_two", table: "Strings", bundle: .module) }
        }
        
        public extension TypedStringsWithArguments {

            var pluralOne: TypedStringConfig { (key: "PluralOne", table: "Strings", bundle: .module) }
        }\n
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
                                    value: "test %@"
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
                ),
                bundle: .module
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
                ),
                bundle: .module
            )
        ]

        let expected = """
        //
        //  TypedStrings.swift
        //  This file was automatically generated and should not be edited.
        //

        import SwiftTypedResources
        
        public extension TypedStrings {

            // MARK: First
            var firstDefaultOne: TypedStringConfig { (key: "DefaultOne", table: "First", bundle: .module) }
            var firstDefaultTwo: TypedStringConfig { (key: "DefaultTwo", table: "First", bundle: .module) }

            // MARK: Second
            var secondDefaultOne: TypedStringConfig { (key: "DefaultOne", table: "Second", bundle: .module) }
            var secondDefaultTwo: TypedStringConfig { (key: "DefaultTwo", table: "Second", bundle: .module) }
        }
        
        public extension TypedStringsWithArguments {

            // MARK: First
            var firstPluralOne: TypedStringConfig { (key: "PluralOne", table: "First", bundle: .module) }
        
            // MARK: Second
            var secondPluralOne: TypedStringConfig { (key: "PluralOne", table: "Second", bundle: .module) }
        }\n
        """
        let real = generator.generateFileContent(
            for: resources,
            fileName: "TypedStrings.swift"
        )
        #expect(expected == real)
    }
}
