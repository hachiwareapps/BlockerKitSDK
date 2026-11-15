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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.41.0/BlockerKit.xcframework.zip",
            checksum: "59f4c1e26bb3522790ad59b72476796e457ae65a5a28dbd24edaffbc49bd26fe"
        )
    ]
)
