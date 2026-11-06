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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.34.0/BlockerKit.xcframework.zip",
            checksum: "3a2ba6ca0bbeaac7eaa42839ffa9f98393a580239577786b2ab6fd8365b4f0f2"
        )
    ]
)
