# BlockerKitSDK

BlockerKitSDK は、EasyList / AdGuard 形式のフィルターテキストを iOS / macOS の `WKWebView` で使うための binary Swift Package です。
BlockerKit を XCFramework として配布しているため、このリポジトリにはソースコードを含みません。

## できること

- Safari Content Blocker の `WKContentRuleList` に渡せる JSON を生成する。
- cosmetic rule、CSS injection、一部の scriptlet を `WKUserScript` ランタイムとして適用する。
- 変換できないルールや近似変換になるルールを診断情報として取得する。
- opt-in の advanced mode で、`WKURLSchemeHandler` を使う追加の変換結果を生成する。

## 要件

- iOS 17.0 以上 / macOS 12.0 以上
- Swift 5.9 以上

## 導入

Xcode の Swift Package Dependencies から、この package を追加してください。

```swift
.package(url: "https://github.com/hachiwareapps/BlockerKitSDK.git", from: "0.2.0")
```

アプリターゲットから `BlockerKit` product をリンクします。

## 使い方

`BlockerKitCompiler` でフィルターテキストを変換し、生成された UserScript と content rule list を `WKWebViewConfiguration` に登録します。

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

if let ruleList = try await WKContentRuleListStore.default()
    .compileBlockerKitContentRuleList(identifier: "main", from: bundle) {
    configuration.userContentController.add(ruleList)
}

let webView = WKWebView(frame: .zero, configuration: configuration)
```

## リリース情報

- Release tag: `0.2.0`
- Source repository: `hachiwareapps/BlockerKit`
- Source commit: `a1ee4ecff70e39180c310195b72dd65d4d766c5e`
- Artifact: [BlockerKit.xcframework.zip](https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.2.0/BlockerKit.xcframework.zip)
- SwiftPM checksum: `30cb5d6ec1f2caf6810bd77de3b2ac374e7a0814a2a228168cc5b1636542e07d`
