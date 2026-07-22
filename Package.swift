// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BlockerKitSDK",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BlockerKit",
            targets: ["BlockerKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "BlockerKit",
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.12.0/BlockerKit.xcframework.zip",
            checksum: "c3b4cefa6f8c318b23549d18c839fc9fb2f95949159a1272925b1b68c3bbe621"
        )
    ]
)
