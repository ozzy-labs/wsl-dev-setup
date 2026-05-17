---
name: correctness
category: required
description: ロジック誤り・エッジケース・並行性・エラーハンドリング
applies_when: ["**/*"]
default_enabled: true
severity_rules: { critical: "悪用・データ破壊・誤った状態遷移・無限ループ・回帰の温床になり得るバグ", warning: "通常パスは動くが特定入力で破綻するケース、未処理の例外", info: "防御的コーディングの改善余地、より堅牢な書き方の提案" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# correctness — 正確性

## 検査項目

- **ロジック誤り**: 条件分岐の取りこぼし、off-by-one、boolean 反転、誤った演算子
- **エッジケース**: 空入力、null / undefined、最大/最小値、空配列・空文字列、Unicode、改行
- **並行性**: race condition、競合する書き込み、shared state の取り扱い、await 漏れ、Promise の handling
- **エラーハンドリング**: 握りつぶし（catch して何もしない）、誤った再 throw、エラー型の取り違え、finally の副作用
- **戻り値・副作用**: 関数が宣言した契約を満たしているか、未文書化の副作用がないか
- **型の整合**: `as` キャストや `any` 経由で実行時に破綻するパスがないか

## severity ガイド

- **critical**: 悪用・データ破壊・誤った状態遷移・無限ループ・回帰の温床になり得るバグ
- **warning**: 通常パスは動くが特定入力で破綻するケース、未処理の例外
- **info**: 防御的コーディングの改善余地、より堅牢な書き方の提案

## skip_when

なし（required 観点は常に適用）。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

正確性に関する critical / warning が残っている状態で merge-ready とは判定しない。
