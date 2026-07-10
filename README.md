# BlockerKitSDK

BlockerKitSDK は、EasyList / AdGuard 形式のフィルターテキストを iOS / macOS の `WKWebView` で使うための binary Swift Package です。
BlockerKit 本体は XCFramework として配布しているため、このリポジトリには BlockerKit 本体のソースコードを含みません。

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
.package(url: "https://github.com/hachiwareapps/BlockerKitSDK.git", from: "0.3.0")
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

## GPL フィルター資産の再生成

この repository には、public upstream filter repository から GPL フィルター資産を再生成するための最小 CLI `gpl-filter-compiler` も含まれます。
private `BlockerKit` や private `FilterAssetsUpdater` なしに、公開された `BlockerKitSDK` と upstream filter だけで変換できます。

固定 upstream commit を記録した manifest を作成します。

```sh
ADGUARD_COMMIT="$(git ls-remote https://github.com/AdguardTeam/AdguardFilters.git HEAD | awk '{print $1}')"
EASYLIST_COMMIT="$(git ls-remote https://github.com/easylist/easylist.git HEAD | awk '{print $1}')"

cat > filter-sources.json <<JSON
{
  "sources": [
    {
      "name": "adguard-filters",
      "upstreamURL": "https://github.com/AdguardTeam/AdguardFilters.git",
      "commit": "$ADGUARD_COMMIT",
      "maxRulesPerChunk": 3000,
      "includedDirectories": [
        { "path": "BaseFilter/sections", "outputPrefix": "adguard_base" },
        { "path": "JapaneseFilter/sections", "outputPrefix": "adguard_japanese" }
      ]
    },
    {
      "name": "easylist",
      "upstreamURL": "https://github.com/easylist/easylist.git",
      "commit": "$EASYLIST_COMMIT",
      "maxRulesPerChunk": 3000,
      "includedDirectories": [
        { "path": "easylist", "outputPrefix": "easylist" },
        { "path": "easylist_adult", "outputPrefix": "easylist_adult" }
      ]
    }
  ]
}
JSON
```

compiler を実行します。

```sh
swift run gpl-filter-compiler \
  --source-manifest filter-sources.json \
  --output-dir outputs/filter-assets \
  --report-dir outputs/reports
```

生成される asset file は `FilterAssets` と同じ filename convention を使います。

- `ContentRuleList-adguard_base_*.json`
- `ContentRuleList-adguard_japanese_*.json`
- `ContentRuleList-easylist_easylist_*.json`
- `ContentRuleList-easylist_adult_*.json`

output directory には `checksums.sha256` も生成されます。
report directory には未対応ルール、WebKit validation で drop されたルール、source ごとの conversion report、`conversion-summary.json` が生成されます。

## リリース情報

- Release tag: `0.3.0`
- Source repository: `hachiwareapps/BlockerKit`
- Source commit: `1b095fa8e5c0700d067ed6c2f75b42d81754b5dc`
- Artifact: [BlockerKit.xcframework.zip](https://github.com/hachiwareapps/BlockerKitSDK/releases/download/0.3.0/BlockerKit.xcframework.zip)
- SwiftPM checksum: `cc50adfea835c4fe508400188d1307363978c333355ba6f8a523d82a918caaca`
