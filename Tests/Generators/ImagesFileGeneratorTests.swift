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

            var base: TypedImageConfig { (name: "base", bundle: .module) }
            var base2: TypedImageConfig { (name: "base2", bundle: .module) }
            var flexTwo: TypedImageConfig { (name: "Flex.Two", bundle: .module) }
            var testOne: TypedImageConfig { (name: "test-One", bundle: .module) }
            var testThree: TypedImageConfig { (name: "Test.Three", bundle: .module) }
            var testTwo: TypedImageConfig { (name: "_test_two", bundle: .module) }
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
            var oneTestOne: TypedImageConfig { (name: "oneTest-One", bundle: .module) }
            var oneTestThree: TypedImageConfig { (name: "oneTest.Three", bundle: .module) }
            var oneTestTwo: TypedImageConfig { (name: "one_test_two", bundle: .module) }
        
            // MARK: Two
            var twoTestOne: TypedImageConfig { (name: "twoTest-One", bundle: .module) }
            var twoTestThree: TypedImageConfig { (name: "twoTest.Three", bundle: .module) }
            var twoTestTwo: TypedImageConfig { (name: "two_test_two", bundle: .module) }
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
            var oneTestOne: TypedImageConfig { (name: "test-One", bundle: .module) }
            var oneTestThree: TypedImageConfig { (name: "Test.Three", bundle: .module) }
            var oneTestTwo: TypedImageConfig { (name: "_test_two", bundle: .module) }

            // MARK: Two
            var twoTestOne: TypedImageConfig { (name: "test-One", bundle: .module) }
            var twoTestThree: TypedImageConfig { (name: "Test.Three", bundle: .module) }
            var twoTestTwo: TypedImageConfig { (name: "_test_two", bundle: .module) }
        }
        """
        let real = generator.generateFileContent(
            for: resources,
            fileName: "TypedImages.swift"
        )
        #expect(expected == real)
    }
}
