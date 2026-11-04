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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.32.0/BlockerKit.xcframework.zip",
            checksum: "abe68b1940259c59e05ed5d4c642e7aaf7add9f4e322a34e5a0551841a1a9719"
        )
    ]
)
