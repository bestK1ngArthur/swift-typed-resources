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

        public extension TypedImages {

            public let base = "base"
            public let base2 = "base2"
            public let flexTwo = "Flex.Two"
            public let testOne = "test-One"
            public let testThree = "Test.Three"
            public let testTwo = "_test_two"
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

        public extension TypedImages {

            // MARK: One
            public let oneTestOne = "oneTest-One"
            public let oneTestThree = "oneTest.Three"
            public let oneTestTwo = "one_test_two"
        
            // MARK: Two
            public let twoTestOne = "twoTest-One"
            public let twoTestThree = "twoTest.Three"
            public let twoTestTwo = "two_test_two"
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

        public extension TypedImages {

            // MARK: One
            public let oneTestOne = "test-One"
            public let oneTestThree = "Test.Three"
            public let oneTestTwo = "_test_two"

            // MARK: Two
            public let twoTestOne = "test-One"
            public let twoTestThree = "Test.Three"
            public let twoTestTwo = "_test_two"
        }
        """
        let real = generator.generateFileContent(
            for: resources,
            fileName: "TypedImages.swift"
        )
        #expect(expected == real)
    }
}
