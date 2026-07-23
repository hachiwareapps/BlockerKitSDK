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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.13.0/BlockerKit.xcframework.zip",
            checksum: "dd89ca6a8fd05acb814e57eccefaaaa3d2d46725ced8eb8f08c8216abf29cd66"
        )
    ]
)
