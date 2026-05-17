---
name: architecture
category: design
description: レイヤリング・責務配置・抽象度・既存パターン整合
applies_when: ["src/**", "scripts/**", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py"]
skip_when: { diff_only_in: ["**/*.md", "docs/**", "**/*.yaml", "**/*.yml", "**/*.json"] }
default_enabled: true
severity_rules: { critical: "既存アーキテクチャ判断 (ADR 等) に明確に反する、取り返しがつかない構造変更", warning: "責務違反、循環依存、既存パターンを破る無理筋、保守性を著しく下げる構造", info: "より良い分離・命名・抽象度の提案、リファクタリング候補" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# architecture — アーキテクチャ

## 検査項目

- **レイヤリング**: 上位層が下位層を参照しているか、循環依存がないか
- **責務配置**: 1 モジュール / 関数の責務が明確で過剰膨張していないか
- **抽象度**: 適切な抽象化レベル、不要な抽象 / 早期最適化、漏れている抽象化
- **既存パターンとの整合**: adapter / skill / agent などのリポジトリ既存パターンに沿っているか、独自パターン乱立していないか
- **データフロー**: 入出力の方向、グローバル状態の混入、純粋性の意図的な維持
- **拡張性**: 将来の差し込みポイント、過剰な extension point の設置（YAGNI）
- **境界の明示**: モジュール / パッケージ / 内部 API / 外部 API の境界が明示されているか

## severity ガイド

- **critical**: 既存アーキテクチャ判断（ADR 等）に明確に反する、取り返しがつかない構造変更
- **warning**: 責務違反、循環依存、既存パターンを破る無理筋、保守性を著しく下げる構造
- **info**: より良い分離・命名・抽象度の提案、リファクタリング候補

## skip_when

ドキュメント・設定ファイルのみの変更ではアーキテクチャ観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
    warning: 0
```

設計レベルの critical / warning が残っている状態で merge-ready とは判定しない。
