---
name: conventions
category: required
description: Conventional Commits、lint、ファイル命名、`.yaml` 統一などのリポジトリ規約
applies_when: ["**/*"]
default_enabled: true
severity_rules: { critical: "コミット / PR タイトルが Conventional Commits 違反 (commitlint で fail)、main への直接 push、--no-verify 利用", warning: "lint / formatter 違反、命名規約違反、.yaml / .yml 不整合", info: "より明示的な書き方への改善提案、命名の細かな統一" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# conventions — コーディング規約

## 検査項目

- **Conventional Commits**: type / scope / description の形式、`!` による破壊的変更マーキング
- **ブランチ命名**: `<type>/<short-description>` 形式
- **ファイル命名・配置**: 既存パターンとの整合（`SKILL.md` / `SKILL.<adapter>.md`、`perspectives/<axis>.md` など）
- **YAML 拡張子**: `.yaml` に統一されているか（ツールが `.yml` を要求する場合のみ許容）
- **lint / formatter**: biome / markdownlint / yamllint / shellcheck / shfmt 等の出力に違反していないか
- **import / export 規約**: ESM / CJS の統一、明示的なファイル拡張子
- **CLAUDE.md / AGENTS.md**: 記載されたプロジェクトルールに違反していないか
- **言語別規約**: tools/lint-rules.md などで定義された言語固有の規約

## severity ガイド

- **critical**: コミット / PR タイトルが Conventional Commits 違反（commitlint で fail）、`main` への直接 push、`--no-verify` 利用
- **warning**: lint / formatter 違反、命名規約違反、`.yaml` / `.yml` 不整合
- **info**: より明示的な書き方への改善提案、命名の細かな統一

## skip_when

```yaml
skip_when:
  diff_only_in: []
```

required 観点のため常に適用する。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

規約違反が残っている状態で merge-ready とは判定しない。
