# BlockerKitSDK

BlockerKitSDK distributes BlockerKit as a binary Swift Package. This repository is intended to be public and does not contain BlockerKit source code.

## Requirements

- iOS 17.0 or later / macOS 12.0 or later
- Swift 5.9 or later

## Installation

Add this package in Xcode:

```swift
.package(url: "https://github.com/hachiwareapps/BlockerKitSDK.git", branch: "main")
```

Link the `BlockerKit` product from your app target, then import the module:

```swift
import BlockerKit
import WebKit

let filterText = """
||ads.example.com^$script,third-party
example.com##.ad-banner
"""

let bundle = try BlockerKitCompiler(engineMode: .standard).compile(filterText)

let configuration = WKWebViewConfiguration()
configuration.userContentController.addBlockerKitUserScripts(from: bundle)
```

## Release

- Release tag: `main-858204a3f17e`
- Source repository: `hachiwareapps/BlockerKit`
- Source commit: `858204a3f17e4cc044b3aea4f4bd5062fc60c02a`
- Artifact: [BlockerKit.xcframework.zip](https://github.com/hachiwareapps/BlockerKitSDK/releases/download/main-858204a3f17e/BlockerKit.xcframework.zip)
- SwiftPM checksum: `75d8d5867fb27787d3d4664e4becdf0fea5a9c47a8322bd24afd89909e96720c`
