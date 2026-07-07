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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.2.0/BlockerKit.xcframework.zip",
            checksum: "30cb5d6ec1f2caf6810bd77de3b2ac374e7a0814a2a228168cc5b1636542e07d"
        )
    ]
)
