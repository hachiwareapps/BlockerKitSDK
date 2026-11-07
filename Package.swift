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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.35.0/BlockerKit.xcframework.zip",
            checksum: "dcbf0b8ef5b0b19e2fee6b5bbc9df1a0728d0c11766b5b43ee80fd45d943f76c"
        )
    ]
)
