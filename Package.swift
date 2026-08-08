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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.16.0/BlockerKit.xcframework.zip",
            checksum: "c464f02243e09cad851b392d59e05abca8b55a20ca34d4ed4d5ce1f84b6fa634"
        )
    ]
)
