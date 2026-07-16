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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.6.0/BlockerKit.xcframework.zip",
            checksum: "ff729af20b6379b2ccb3ed8172bd8df2dcd73f1ab312a8c788bf8fe20e585a47"
        )
    ]
)
