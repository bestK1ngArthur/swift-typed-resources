# Swift Typed Resources

Simple Swift Package to generate typed resources (via keypath mechanism) for iOS apps in code such as Strings or Images. Inspired by [R.swift](https://github.com/mac-cain13/R.swift).

## Example

```swift
struct SettingsView: View {
    var body: some View {
        Text(\.settingsDataTitle)
    }
}
```

## Supported File Types

| 🔠 Strings | 🖼️ Images|
| ------------- | ------------- |
| ✅ .xcstrings | ✅ .xcassets |

## Usage in Swift Package

### Install

You can add **swift-typed-resources** to an Swift Package by adding it as a dependency.

```swift
let package = Package(
    name: "MyPackage",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(
            name: "MyPackage",
            targets: ["MyPackage"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/bestK1ngArthur/swift-typed-resources.git", exact: "0.0.6")
    ],
    targets: [
        .target(
            name: "MyPackage",
            dependencies: [
                .product(name: "SwiftTypedResources", package: "swift-typed-resources")
            ],
            resources: [.process("Resources")]
        )
    ]
)
```

### Generate

1. Right-click on **MyPackage** to show Xcode context menu.
2. Then select **GenerateResources** in **swift-typed-resources** section to generate swift files.

<img width="311" alt="Screenshot 2024-12-26 at 13 12 09" src="https://github.com/user-attachments/assets/9ae5b1fc-2337-44e1-89a3-ee2277b99866" />

### Generated Files Example

#### Generated/TypedStrings.swift

```swift
import SwiftTypedResources

public extension TypedStrings {

    // MARK: Main
    var mainActivity: TypedStringConfig { (key: "Main.Activity", table: "Localizable", bundle: .module) }
    var mainAppName: TypedStringConfig { (key: "Main.AppName", table: "Localizable", bundle: .module) }
}
```

#### Generated/TypedImages.swift

```swift
import SwiftTypedResources

public extension TypedImages {

    // MARK: App Icons
    var appIconClassicPreview: TypedImageConfig { (name: "AppIcon-Classic-Preview", bundle: .module) }
    var appIconFreshPreview: TypedImageConfig { (name: "AppIcon-Fresh-Preview", bundle: .module) }
}
```
