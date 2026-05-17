---
name: perspectives-index
description: review skill が参照する観点定義のインデックスとスキーマガイド。
---

# review perspectives

review skill / `code-reviewer` agent が参照する観点定義の SSOT（[ADR-0025](https://github.com/ozzy-labs/handbook/blob/main/adr/0025-skills-review-multi-perspective.md)）。各 `<axis>.md` がレビュー 1 観点を表し、frontmatter に観点メタデータ、本文に検査項目・severity ガイド・終了基準を持つ。

## 採用観点（11 軸）

| category | axis | 既定 |
| --- | --- | --- |
| required | [correctness](./correctness.md) | 常に適用 |
| required | [security](./security.md) | 常に適用 |
| required | [conventions](./conventions.md) | 常に適用 |
| design | [architecture](./architecture.md) | applies_when マッチ時 |
| design | [compatibility](./compatibility.md) | applies_when マッチ時 |
| design | [maintainability](./maintainability.md) | applies_when マッチ時 |
| quality | [testing](./testing.md) | applies_when マッチ時 |
| quality | [performance](./performance.md) | applies_when マッチ時 |
| quality | [observability](./observability.md) | applies_when マッチ時 |
| ux | [usability](./usability.md) | applies_when マッチ時、consumer が opt-out 可 |
| ux | [documentation](./documentation.md) | 常に適用 |

## frontmatter スキーマ

```yaml
---
name: <axis>                                                    # ファイル名と一致させる
category: required | design | quality | ux
description: <一行で観点の主旨>
applies_when: ["<glob>", ...]                                   # diff にこの glob にマッチするファイルが含まれれば適用
skip_when: { diff_only_in: ["<glob>", ...] }                    # 全変更ファイルがこの glob 部分集合なら不適用
default_enabled: true | false                                   # false の場合は --axes 明示時のみ適用
severity_rules: { critical: "<...>", warning: "<...>", info: "<...>" }
exit_criteria: { drive_loop: { critical: <N>, warning: <N> } }  # warning キーは省略可（許容を意味する）
---
```

`skip_when` / `severity_rules` / `exit_criteria` は flow-style YAML の 1 行で記述する（既存の flat frontmatter parser と整合させるため）。本文には人間可読な severity ガイドや検査項目を冗長に記述してよいが、機械処理の SSOT は frontmatter とする。

未定義キーは reader が無視する（forward-compat）。互換破壊的なスキーマ変更（必須キーの削除等）は ADR を起こす。

## 観点選別ロジック

review skill / `code-reviewer` agent は以下の順で適用観点を決定する:

1. `category: required` → 常に適用（`applies_when` / `skip_when` を無視）
2. `default_enabled: false` → `--axes` で明示指定された場合のみ適用（experimental 用）
3. `skip_when.diff_only_in` がマッチ → 不適用（最優先のスキップ条件）
4. `applies_when` のいずれかの glob にマッチ → 適用（OR）
5. それ以外 → 不適用

## 観点 MD の追加・変更

新しい観点を追加する場合、本ディレクトリに `<axis>.md` を作成して frontmatter スキーマに従い記述する。観点 MD の lint（frontmatter 必須キー検証、`applies_when` / `skip_when` の glob 妥当性）は `health` skill で実施する。

互換破壊的なスキーマ変更（必須キーの削除等）を行う場合は ADR を起こす。`code-reviewer` agent と review skill 双方の reader が後方互換に追随できるよう、新キーは optional として導入する。
