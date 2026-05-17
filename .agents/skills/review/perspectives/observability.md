---
name: observability
category: quality
description: エラー文脈・ログ・失敗時の手がかり
applies_when: ["src/**", "scripts/**", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py", "**/*.sh"]
skip_when: { diff_only_in: ["**/*.md", "docs/**", "tests/**", "**/*.test.*", "**/*.yaml", "**/*.yml", "**/*.json"] }
default_enabled: true
severity_rules: { critical: "失敗時に何も情報が出ず原因特定不可能、本番で silent failure になる経路", warning: "エラーメッセージが薄い、ログ過剰 / 不足、エラー種別の取り違え", info: "より親切なメッセージ、log level の調整提案" }
exit_criteria: { drive_loop: { critical: 0 } }
---

# observability — 可観測性

## 検査項目

- **エラー文脈**: throw する error に十分な手がかり（入力値・どのファイル・どの操作）が含まれているか
- **ログ**: 失敗時に何が起きたか追える程度のログがあるか、過剰な debug ログを残していないか
- **エラーメッセージの粒度**: ユーザに表示する文言が actionable か（次の手が示唆されるか）
- **失敗の伝播**: 上位がエラー種別で分岐できる構造か、error code / typed error の活用
- **副作用の追跡可能性**: 外部システム（GitHub API / fs / network）呼び出しの成否が可視化されているか
- **シークレット漏洩防止**: ログに secret が出ていないか
- **CI / Hook の失敗表示**: lefthook / hook の失敗時に原因がすぐ分かる出力か

## severity ガイド

- **critical**: 失敗時に何も情報が出ず原因特定不可能、本番で silent failure になる経路
- **warning**: エラーメッセージが薄い、ログ過剰 / 不足、エラー種別の取り違え
- **info**: より親切なメッセージ、log level の調整提案

## skip_when

テスト・ドキュメント・設定のみの変更では可観測性観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
```

可観測性の warning は許容。critical は阻止する。
