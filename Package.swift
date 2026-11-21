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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.44.0/BlockerKit.xcframework.zip",
            checksum: "0406020d1982aaa7bf919b50e4de40f9425d2c8c1f4306d8e7d44b23b79c2df1"
        )
    ]
)
