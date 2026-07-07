# BlockerKitSDK

BlockerKitSDK distributes BlockerKit as a binary Swift Package. This repository is intended to be public and does not contain BlockerKit source code.

## Requirements

- iOS 17.0 or later / macOS 12.0 or later
- Swift 5.9 or later

## Installation

Add this package in Xcode:

```swift
.package(url: "https://github.com/hachiwareapps/BlockerKitSDK.git", from: "0.1.0")
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

- Release tag: `0.1.0`
- Source repository: `hachiwareapps/BlockerKit`
- Source commit: `228dff2f2e1d5e9f20d19ff7cab97c89af15cb98`
- Artifact: [BlockerKit.xcframework.zip](https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.1.0/BlockerKit.xcframework.zip)
- SwiftPM checksum: `3e762ddef6afbf064d6f61ac1781c08d866f490fd9dc7e7d4a95a88f4ad30f5c`
