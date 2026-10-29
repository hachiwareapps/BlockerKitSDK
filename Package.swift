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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.29.0/BlockerKit.xcframework.zip",
            checksum: "2cce438b28bb7a56a1d48fa9a33dd5c3787fb1b156f358282ad53eff647d3f2d"
        )
    ]
)
