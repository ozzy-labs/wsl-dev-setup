---
name: security
category: required
description: 注入・秘密情報露出・権限昇格・サプライチェーン・スクリプト実行
applies_when: ["**/*"]
default_enabled: true
severity_rules: { critical: "悪用可能な脆弱性、明示的な秘密情報の commit、認証回避、任意コード実行", warning: "防御層の欠落、未サニタイズ入力、過剰な権限、暗黙の信頼境界", info: "改善余地のある defensive coding、CSP / セキュリティヘッダの強化提案" }
exit_criteria: { drive_loop: { critical: 0, warning: 0 } }
---

# security — セキュリティ

## 検査項目

- **注入**: コマンドインジェクション、SQL/NoSQL injection、shell の `eval`、未エスケープのテンプレート展開、prompt injection
- **秘密情報の露出**: ハードコードされたトークン・API キー・パスワード、`.env` の commit、ログへの secret 漏洩
- **権限昇格**: 過剰な権限を持つ token / IAM ポリシー、`sudo` の不要利用、root 実行
- **サプライチェーン**: 信頼できないレジストリ、未固定の依存、unverified なスクリプト実行（`curl | bash`）
- **スクリプト実行**: 外部入力を eval / spawn に流す、unsanitized URL fetch、ユーザ入力を含む `child_process`
- **CI/CD ワークフロー**: `pull_request_target`、`run-on-pr` の secret 露出、third-party action の SHA 固定漏れ
- **データの取り扱い**: PII の不要な保持・送信、暗号化漏れ、TLS なしの通信

## severity ガイド

- **critical**: 悪用可能な脆弱性、明示的な秘密情報の commit、認証回避、任意コード実行
- **warning**: 防御層の欠落、未サニタイズ入力、過剰な権限、暗黙の信頼境界
- **info**: 改善余地のある defensive coding、CSP / セキュリティヘッダの強化提案

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

security に関する critical / warning が残っている状態で merge-ready とは判定しない。
