---
name: compatibility
category: design
description: 後方互換、スキーマ変更、commons-sync 経由のコンシューマ影響
applies_when: ["src/**", "scripts/**", "dist/**", "package.json", "**/*.json", "**/*.yaml", "**/*.yml", "**/SKILL.md"]
skip_when: { diff_only_in: ["tests/**", "**/*.test.*"] }
default_enabled: true
severity_rules: { critical: "既存コンシューマが破壊される非互換変更 (rename / 削除 / 型変更) で migration path や CHANGELOG への記載がない", warning: "互換性は保てるがコンシューマ側で対応が必要、または default 変更で挙動が変わる", info: "より丁寧な deprecation の提案、注意喚起" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# compatibility — 互換性

## 検査項目

- **後方互換**: 公開 API / CLI フラグ / skill 引数の削除・改名、デフォルト値変更による既存利用者への影響
- **スキーマ変更**: SKILL.md frontmatter / 設定ファイル / JSON schema のフィールド削除・型変更
- **commons-sync 経由のコンシューマ影響**: `dist/` 出力構造の変更がコンシューマの sync で破壊的にならないか
- **agent / adapter API**: `AdapterBase.generate()` シグネチャ変更、`Skill` 型の必須フィールド追加
- **package.json**: dependency / engines の互換性、major bump
- **legacy resume 互換**: 既存 PR コメント・既存 lock / state ファイルなどの読み取り互換
- **version migration**: schema version をインクリメントする変更で reader 側のフォールバック処理を提供しているか

## severity ガイド

- **critical**: 既存コンシューマが破壊される非互換変更（rename / 削除 / 型変更）で migration path や CHANGELOG への記載がない
- **warning**: 互換性は保てるがコンシューマ側で対応が必要、または default 変更で挙動が変わる
- **info**: より丁寧な deprecation の提案、注意喚起

## skip_when

テストのみの変更では互換性観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

非互換変更が未対処のまま merge-ready とは判定しない。
