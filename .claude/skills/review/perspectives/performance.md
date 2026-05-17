---
name: performance
category: quality
description: hot path、不要な逐次 I/O、メモリ
applies_when: ["src/**", "scripts/**", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py"]
skip_when: { diff_only_in: ["**/*.md", "docs/**", "tests/**", "**/*.test.*", "**/*.yaml", "**/*.yml", "**/*.json"] }
default_enabled: true
severity_rules: { critical: "顕著な性能退行、production で UX を損なう規模のリグレッション、無限ループ", warning: "hot path 上の非効率、逐次 I/O、明らかな再計算", info: "軽微な最適化提案、cache 化候補" }
exit_criteria: { drive_loop: { critical: 0 } }
---

# performance — パフォーマンス

## 検査項目

- **hot path**: 高頻度呼び出しパスにおける O(n²) 以上の処理、ネストループ、不要な allocation
- **逐次 I/O**: 並列化可能な独立 I/O を直列で実行していないか（`for await` 直列化、Promise.all 化漏れ）
- **メモリ**: 不要に巨大な中間配列、ストリーム化できる処理の一括読込、リーク要因（hold する closure）
- **不要なレンダリング / 再計算**: memo / cache を活用すべき箇所、毎回計算される定数
- **ファイル I/O**: 同一ファイルの重複読込、無駄な fs stat、巨大ファイルの全読み
- **HTTP / fetch**: タイムアウト未設定、N+1 リクエスト、過度な polling 間隔
- **依存の影響**: 重量級ライブラリの導入、tree-shaking 効きにくい構造

## severity ガイド

- **critical**: 顕著な性能退行、production で UX を損なう規模のリグレッション、無限ループ
- **warning**: hot path 上の非効率、逐次 I/O、明らかな再計算
- **info**: 軽微な最適化提案、cache 化候補

## skip_when

テスト・ドキュメント・設定のみの変更ではパフォーマンス観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
```

性能 warning は許容（merge 後の継続改善対象）。critical は阻止する。
