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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.5.0/BlockerKit.xcframework.zip",
            checksum: "b91ae7e1d6b5318ebaa0c475212880c7407ba35c19a734efab04a4624ad7f5a9"
        )
    ]
)
