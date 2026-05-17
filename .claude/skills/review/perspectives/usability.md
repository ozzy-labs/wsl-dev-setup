---
name: usability
category: ux
description: CLI 文言・エラーメッセージ・skill argument-hint・README 即座理解性
applies_when: ["src/**", "**/*.md", "**/SKILL.md", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py", "**/*.sh"]
skip_when: { diff_only_in: ["tests/**", "**/*.test.*"] }
default_enabled: true
severity_rules: { critical: "ユーザーが詰まる致命的な UX 不備 (無限ループ的な確認、復旧不可能な操作の無確認実行)", warning: "紛らわしいメッセージ、誤解を招く CLI 文言、argument-hint の欠落", info: "より親切な文言、説明追記、UX の細かな改善" }
exit_criteria: { drive_loop: { critical: 0 } }
---

# usability — ユーザビリティ / DX

## 検査項目

- **CLI 文言**: help / usage 表示、フラグ名の直感性、`--<flag>` の命名規則統一
- **エラーメッセージ**: 何が原因で何をすればよいかが伝わるか、ユーザー操作で対処可能か
- **skill / agent の argument-hint**: 期待される引数形式が一目で分かるか
- **README 即座理解性**: 最初の画面で何を提供する skill / package か理解できるか
- **失敗時のリカバリ手順**: ハッピーパス以外で詰まらない設計、再実行可能性
- **デフォルト値**: 一般的なケースで設定なしで動くか、安全側に倒れているか
- **AskUserQuestion**: ユーザーへの確認が AskUserQuestion を使っているか、テキスト出力で選択肢を列挙していないか（CLAUDE.md ルール）
- **国際化**: メッセージが日本語 / 英語のどちらかに統一されているか、混在していないか

## severity ガイド

- **critical**: ユーザーが詰まる致命的な UX 不備（無限ループ的な確認、復旧不可能な操作の無確認実行）
- **warning**: 紛らわしいメッセージ、誤解を招く CLI 文言、argument-hint の欠落
- **info**: より親切な文言、説明追記、UX の細かな改善

## skip_when

テストのみの変更ではユーザビリティ観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
```

ユーザビリティの warning は許容（merge 後の継続改善対象）。critical は阻止する。
