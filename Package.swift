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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.24.0/BlockerKit.xcframework.zip",
            checksum: "43c2f1c3d783a489b00333f7ca291716cc7b9c1b92b9f51b0e72cbd86188d72a"
        )
    ]
)
