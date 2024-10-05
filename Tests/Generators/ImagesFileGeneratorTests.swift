//
//  ImagesFileGeneratorTests.swift
//  swift-typed-resources
//
//  Created by Artem Belkov on 05.10.2024.
//  Copyright © 2024 Artem Belkov. All rights reserved.
//

@testable import SwiftTypedResourcesGenerators

import Foundation
import SwiftTypedResourcesModels
import Testing

@Suite("Images's File Generator Tests")
struct ImagesFileGeneratorTests {

    private let generator = ImagesFileGenerator()

    @Test
    func generate_oneTable() throws {
        let resource = ImagesResource(
            table: "Images",
            assets: [
                "test-One": .imageAsset(.init(fileName: "test-One")),
                "_test_two": .imageAsset(.init(fileName: "_test_two")),
                "Test.Three": .imageAsset(.init(fileName: "Test.Three")),
                "Flex.Two": .imageAsset(.init(fileName: "Flex.Two")),
                "base2": .imageAsset(.init(fileName: "base2")),
                "base": .imageAsset(.init(fileName: "base"))
            ]
        )
        let expected = """
        //
        //  TypedImages.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        import SwiftTypedResources
        
        public extension TypedImages {

            var base: String { "base" }
            var base2: String { "base2" }
            var flexTwo: String { "Flex.Two" }
            var testOne: String { "test-One" }
            var testThree: String { "Test.Three" }
            var testTwo: String { "_test_two" }
        }
        """
        let real = generator.generateFileContent(
            for: [resource],
            fileName: "TypedImages.swift"
        )
        #expect(expected == real)
    }

    @Test
    func generate_oneTable_fewFolders() throws {
        let resource = ImagesResource(
            table: "Images",
            assets: [
                "one": .folder(
                    .init(
                        name: "One",
                        assets: [
                            "oneTest-One": .imageAsset(.init(fileName: "oneTest-One")),
                            "one_test_two": .imageAsset(.init(fileName: "one_test_two")),
                            "oneTest.Three": .imageAsset(.init(fileName: "oneTest.Three"))
                        ]
                    )
                ),
                "two": .folder(
                    .init(
                        name: "Two",
                        assets: [
                            "twoTest-One": .imageAsset(.init(fileName: "twoTest-One")),
                            "two_test_two": .imageAsset(.init(fileName: "two_test_two")),
                            "twoTest.Three": .imageAsset(.init(fileName: "twoTest.Three"))
                        ]
                    )
                )
            ]
        )
        let expected = """
        //
        //  TypedImages.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        import SwiftTypedResources
        
        public extension TypedImages {

            // MARK: One
            var oneTestOne: String { "oneTest-One" }
            var oneTestThree: String { "oneTest.Three" }
            var oneTestTwo: String { "one_test_two" }
        
            // MARK: Two
            var twoTestOne: String { "twoTest-One" }
            var twoTestThree: String { "twoTest.Three" }
            var twoTestTwo: String { "two_test_two" }
        }
        """
        let real = generator.generateFileContent(
            for: [resource],
            fileName: "TypedImages.swift"
        )
        #expect(expected == real)
    }

    @Test
    func generate_fewTables() throws {
        let resources: ImagesResources = [
            .init(
                table: "One",
                assets: [
                    "test-One": .imageAsset(.init(fileName: "test-One")),
                    "_test_two": .imageAsset(.init(fileName: "_test_two")),
                    "Test.Three": .imageAsset(.init(fileName: "Test.Three"))
                ]
            ),
            .init(
                table: "Two",
                assets: [
                    "test-One": .imageAsset(.init(fileName: "test-One")),
                    "_test_two": .imageAsset(.init(fileName: "_test_two")),
                    "Test.Three": .imageAsset(.init(fileName: "Test.Three"))
                ]
            )
        ]
        let expected = """
        //
        //  TypedImages.swift
        //  swift-typed-resources
        //
        //  Generated on \(Date().formatted(date: .numeric, time: .omitted)).
        //

        import SwiftTypedResources
        
        public extension TypedImages {

            // MARK: One
            var oneTestOne: String { "test-One" }
            var oneTestThree: String { "Test.Three" }
            var oneTestTwo: String { "_test_two" }

            // MARK: Two
            var twoTestOne: String { "test-One" }
            var twoTestThree: String { "Test.Three" }
            var twoTestTwo: String { "_test_two" }
        }
        """
        let real = generator.generateFileContent(
            for: resources,
            fileName: "TypedImages.swift"
        )
        #expect(expected == real)
    }
}
