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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.4.0/BlockerKit.xcframework.zip",
            checksum: "3e9492aa2a0b33ae5d1402dcc36b772a1b882df00836c7c80cefc86859ab3dc2"
        )
    ]
)
