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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.9.0/BlockerKit.xcframework.zip",
            checksum: "4eab441ab8f9b58bfc8ec53b9411c2a02540b818384494730cfa1ff4249eb01b"
        )
    ]
)
