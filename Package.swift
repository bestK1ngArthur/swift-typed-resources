// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTypedResources",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SwiftTypedResources",
            targets: ["SwiftTypedResources"]
        ),
        .library(
            name: "SwiftTypedResourcesModels",
            targets: ["SwiftTypedResourcesModels"]
        ),
        .library(
            name: "SwiftTypedResourcesParsers",
            targets: ["SwiftTypedResourcesParsers"]
        ),
        .library(
            name: "SwiftTypedResourcesGenerators",
            targets: ["SwiftTypedResourcesGenerators"]
        ),
        .library(
            name: "SwiftTypedResourcesPlugin",
            targets: ["SwiftTypedResourcesPlugin"]
        ),
    ],
    targets: [
        .target(name: "SwiftTypedResources"),
        .target(
            name: "SwiftTypedResourcesModels",
            path: "Sources/Models"
        ),
        .target(
            name: "SwiftTypedResourcesParsers",
            dependencies: ["SwiftTypedResourcesModels"],
            path: "Sources/Parsers"
        ),
        .target(
            name: "SwiftTypedResourcesGenerators",
            dependencies: ["SwiftTypedResourcesModels"],
            path: "Sources/Generators"
        ),
        .target(
            name: "SwiftTypedResourcesPlugin",
            path: "Sources/Plugin"
        ),
        .testTarget(
            name: "SwiftTypedResourcesParsersTests",
            dependencies: ["SwiftTypedResourcesParsers"],
            path: "Tests/Parsers"
        )
    ]
)
