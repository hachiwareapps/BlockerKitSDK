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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.1.0/BlockerKit.xcframework.zip",
            checksum: "3e762ddef6afbf064d6f61ac1781c08d866f490fd9dc7e7d4a95a88f4ad30f5c"
        )
    ]
)
