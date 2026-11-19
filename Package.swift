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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.42.0/BlockerKit.xcframework.zip",
            checksum: "316abc99e309fa5cbcd5f5e4cb39b41c8ae0b550289a9a706223aee81eb7327a"
        )
    ]
)
