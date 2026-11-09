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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.37.0/BlockerKit.xcframework.zip",
            checksum: "b200cf873e25bb3c5a0fcb95549736168ea671d386dc5b8341189f51e324b29a"
        )
    ]
)
