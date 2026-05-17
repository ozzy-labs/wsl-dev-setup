---
name: documentation
category: ux
description: README・AGENTS.md・CLAUDE.md・SKILL.md・公開挙動の同期
applies_when: ["**/*"]
skip_when: { diff_only_in: [] }
default_enabled: true
severity_rules: { critical: "公開 API / 公開 CLI の変更がドキュメントに一切反映されておらず利用者が破壊される", warning: "README / SKILL.md / AGENTS.md の陳腐化、ADR と実装の乖離、誤ったサンプル", info: "ドキュメント追記の提案、説明の改善、表記揺れの統一" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# documentation — ドキュメント整合性

## 検査項目

- **README**: 公開挙動の変更がドキュメントに反映されているか、サンプル / 使用例の陳腐化
- **AGENTS.md / CLAUDE.md**: skill / agent の追加・改名・削除が反映されているか
- **SKILL.md**: frontmatter の `description` / `argument-hint` がコード実装と一致しているか
- **CHANGELOG**: 互換性に影響する変更が記録されているか（release-please 自動生成範囲を除く）
- **コメント / docstring**: 実装変更に追従しているか、誤った説明が残っていないか
- **ADR との整合**: ADR で決定された方針と実装が一致しているか、参照する ADR 番号が正確か
- **public な関数 / API のドキュメント**: 入力 / 出力 / 例外契約が記載されているか

## severity ガイド

- **critical**: 公開 API / 公開 CLI の変更がドキュメントに一切反映されておらず利用者が破壊される
- **warning**: README / SKILL.md / AGENTS.md の陳腐化、ADR と実装の乖離、誤ったサンプル
- **info**: ドキュメント追記の提案、説明の改善、表記揺れの統一

## skip_when

ドキュメント整合性は全変更で適用する（コード変更にもドキュメント変更にも検査対象がある）。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

ドキュメント整合性の critical / warning が残っている状態で merge-ready とは判定しない。
