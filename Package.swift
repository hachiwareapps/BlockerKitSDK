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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.18.0/BlockerKit.xcframework.zip",
            checksum: "190f5c0243a3eb73407d2c5326e454a6e5dbc6a127ab3449eb62bb9699e5f9b5"
        )
    ]
)
