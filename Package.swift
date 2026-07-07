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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/main-858204a3f17e/BlockerKit.xcframework.zip",
            checksum: "75d8d5867fb27787d3d4664e4becdf0fea5a9c47a8322bd24afd89909e96720c"
        )
    ]
)
