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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.36.0/BlockerKit.xcframework.zip",
            checksum: "c7fdcef1ed0cfd004d71bbbb53309dcb4512a3ca457ba25bdd68b2165f364198"
        )
    ]
)
