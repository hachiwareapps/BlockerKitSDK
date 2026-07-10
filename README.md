# BlockerKitSDK

BlockerKitSDK は、EasyList / AdGuard 形式のフィルターテキストを iOS / macOS の `WKWebView` で使うための binary Swift Package です。

## できること

- Safari Content Blocker の `WKContentRuleList` に渡せる JSON を生成する。
- cosmetic rule、CSS injection、一部の scriptlet を `WKUserScript` ランタイムとして適用する。
- 変換できないルールや近似変換になるルールを診断情報として取得する。
- opt-in の advanced mode で、`WKURLSchemeHandler` を使う追加の変換結果を生成する。
