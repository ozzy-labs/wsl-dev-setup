---
name: maintainability
category: design
description: 命名・複雑度・dead code・コメント負債
applies_when: ["src/**", "scripts/**", "**/*.ts", "**/*.tsx", "**/*.mjs", "**/*.js", "**/*.py", "**/*.sh"]
skip_when: { diff_only_in: ["**/*.md", "docs/**", "**/*.yaml", "**/*.yml", "**/*.json"] }
default_enabled: true
severity_rules: { critical: "取り返しのつかない命名 / 構造の選択 (公開 API として固定される名称等)", warning: "顕著な dead code、過剰な複雑度、誤解を招く命名、明らかな重複", info: "命名の細かな改善、コメント整理、軽微なリファクタ提案" }
exit_criteria: { drive_loop: { critical: 0 } }
---

# maintainability — 保守性

## 検査項目

- **命名**: 識別子の意図が伝わるか、誤解を招く命名がないか、不要な略語
- **複雑度**: 関数 / メソッドが過剰に長い、ネストが深すぎる、分岐爆発、cyclomatic complexity
- **dead code**: 未使用の export / 関数 / 変数 / import、コメントアウトされたコード
- **コメント負債**: WHAT を説明する冗長コメント、陳腐化したコメント、TODO / FIXME の放置
- **重複**: 3 箇所以上に出現するロジックや、コピー&ペーストの兆候
- **テスト容易性**: 過剰な隠蔽、副作用に依存した設計、テストしにくい依存注入
- **ドキュメント**: 公開 API / skill / agent に最低限の説明があるか

## severity ガイド

- **critical**: 取り返しのつかない命名 / 構造の選択（公開 API として固定される名称等）
- **warning**: 顕著な dead code、過剰な複雑度、誤解を招く命名、明らかな重複
- **info**: 命名の細かな改善、コメント整理、軽微なリファクタ提案

## skip_when

ドキュメント・設定ファイルのみの変更では保守性観点は適用しない。

## exit_criteria.drive_loop

```yaml
exit_criteria:
  drive_loop:
    critical: 0
```

保守性の warning は許容（merge 後の継続改善対象）。critical は阻止する。
