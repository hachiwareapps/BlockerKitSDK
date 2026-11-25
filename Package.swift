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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.48.0/BlockerKit.xcframework.zip",
            checksum: "dfdfed835a907a4a84826d0fce4fc5085daf45a8a6556c0ee4b461a579d456a9"
        )
    ]
)
