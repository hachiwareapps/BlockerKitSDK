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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.17.0/BlockerKit.xcframework.zip",
            checksum: "be7a0d9e660a012efda8ed7bb4344e76686d5ec8b93cf80689ef34300c4193d8"
        )
    ]
)
