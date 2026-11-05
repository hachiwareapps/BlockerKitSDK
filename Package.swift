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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.33.0/BlockerKit.xcframework.zip",
            checksum: "fa2f3380957592a44273fd4f894ae9caccbeb4a50ac5f270fa6de744b3d30b59"
        )
    ]
)
