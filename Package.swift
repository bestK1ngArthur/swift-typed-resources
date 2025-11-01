// swift-tools-version: 5.10

import PackageDescription

let dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.2")
]

// MARK: - Products

let libraries: [Product] = [
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
    )
]

let executables: [Product] = [
    .executable(
        name: "SwiftTypedResourcesTool",
        targets: ["SwiftTypedResourcesTool"]
    )
]

let plugins: [Product] = [
    .plugin(
        name: "GenerateResources",
        targets: ["GenerateResources"]
    )
]

// MARK: - Targets

let libraryTargets: [Target] = [
    .target(
        name: "SwiftTypedResources",
        path: "Sources/Library"
    ),
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
    )
]

let executableTargers: [Target] = [
    .executableTarget(
        name: "SwiftTypedResourcesTool",
        dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .target(name: "SwiftTypedResourcesParsers"),
            .target(name: "SwiftTypedResourcesGenerators")
        ],
        path: "Sources/Tool"
    )
]

let pluginsTargets: [Target] = [
    .plugin(
        name: "GenerateResources",
        capability: .command(
            intent: .custom(
                verb: "generate-resources",
                description: "Generate resources by command"
            ),
            permissions: [.writeToPackageDirectory(reason: "Write generated files")]
        ),
        dependencies: ["SwiftTypedResourcesTool"],
        path: "Sources/Plugins/GenerateResources"
    )
]

let testsTargets: [Target] = [
    .testTarget(
        name: "SwiftTypedResourcesParsersTests",
        dependencies: ["SwiftTypedResourcesParsers"],
        path: "Tests/Parsers"
    ),
    .testTarget(
        name: "SwiftTypedResourcesGeneratorsTests",
        dependencies: ["SwiftTypedResourcesGenerators"],
        path: "Tests/Generators"
    )
]

// MARK: - Package

let package = Package(
    name: "swift-typed-resources",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: libraries + executables + plugins,
    dependencies: dependencies,
    targets: libraryTargets + executableTargers + pluginsTargets + testsTargets
)
