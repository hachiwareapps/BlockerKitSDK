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
        ),
        .executable(
            name: "gpl-filter-compiler",
            targets: ["GPLFilterCompiler"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "BlockerKit",
            url: "https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.3.0/BlockerKit.xcframework.zip",
            checksum: "cc50adfea835c4fe508400188d1307363978c333355ba6f8a523d82a918caaca"
        ),
        .executableTarget(
            name: "GPLFilterCompiler",
            dependencies: ["BlockerKit"]
        )
    ]
)
