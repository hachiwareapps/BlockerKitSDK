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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.27.0/BlockerKit.xcframework.zip",
            checksum: "4e851e05c30157dc8e43b7b3c0dfe1520eed9af9f18ddfd1275b9848e0a9d596"
        )
    ]
)
