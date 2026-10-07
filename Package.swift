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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.20.0/BlockerKit.xcframework.zip",
            checksum: "a5c7a78144c6a72544d126c562c0bba3b7c1bbbf042c04b06aab41129a1e21f5"
        )
    ]
)
