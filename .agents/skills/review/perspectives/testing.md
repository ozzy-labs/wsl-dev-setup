---
name: testing
category: quality
description: 新コードのカバレッジ、回帰リスク、bats / Vitest / node:test の妥当性
applies_when: ["src/**", "scripts/**", "tests/**", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py", "**/*.sh"]
skip_when: { diff_only_in: ["**/*.md", "docs/**", "**/*.yaml", "**/*.yml", "**/*.json"] }
default_enabled: true
severity_rules: { critical: "公開 API / バグ修正にテストがない、既存テストを根拠なく削除、tautology テスト", warning: "エッジケースの取りこぼし、不安定なテスト (flaky)、mock 過剰", info: "より良いアサーション、テストの整理 / 命名改善" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# testing — テスト

## 検査項目

- **新コードのテスト**: 公開 API / 主要ロジックに対するテストが存在するか
- **エッジケース**: 空入力 / null / 異常系 / 境界値が含まれているか
- **回帰リスク**: 既存テストへの破壊的変更、テスト削除の妥当性、skip / disable の理由
- **テストの質**: アサーションが意味を持つか、tautology テスト（`expect(true).toBe(true)`）になっていないか
- **mocking の境界**: 統合テストで重要な統合点を mock してしまっていないか
- **fixture / snapshot**: 不安定なデータ（時刻 / ランダム）に依存していないか、snapshot の更新理由
- **テストランナー整合**: bats / node:test / Vitest など既存パターンに従っているか
- **CI 実行性**: ローカル専用の前提（特定パス・環境変数）に依存していないか

## severity ガイド

- **critical**: 公開 API / バグ修正にテストがない、既存テストを根拠なく削除、tautology テスト
- **warning**: エッジケースの取りこぼし、不安定なテスト（flaky）、mock 過剰
- **info**: より良いアサーション、テストの整理 / 命名改善

## skip_when

ドキュメント・設定ファイルのみの変更ではテスト観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

公開 API / バグ修正にテストがない状態で merge-ready とは判定しない。
