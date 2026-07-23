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
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.15.0/BlockerKit.xcframework.zip",
            checksum: "b3312ef0ff4b4499f382be64c0e83eb841ae6f78e78d8e16d95ea177fecff355"
        )
    ]
)
