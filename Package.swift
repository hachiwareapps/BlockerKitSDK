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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.50.0/BlockerKit.xcframework.zip",
            checksum: "00288f857ed7a1207ef23ac1c51c97c3afd8c9f190ad5bc42686a3858c4d06d0"
        )
    ]
)
