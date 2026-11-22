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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.45.0/BlockerKit.xcframework.zip",
            checksum: "d8c3b21f43706a06b68719ae58e91a3092c2e68d465a435409105fe180f20755"
        )
    ]
)
