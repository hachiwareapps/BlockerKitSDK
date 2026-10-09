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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.22.0/BlockerKit.xcframework.zip",
            checksum: "6e1b96bea1cf11333c7d654c3bf35fa06b645a8f17bd51e198d04f08648bf75b"
        )
    ]
)
