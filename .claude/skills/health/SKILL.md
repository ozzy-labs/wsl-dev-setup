---
description: リポジトリ改修中に意図せず残る状態と skill catalog 整合性を 16 領域に渡って一発確認し、ステータス表で俯瞰しつつ固定語彙の推奨アクションを inline 付与して報告する。`--deep` 指定時は `要確認` 項目を追加調査してラベルを格上げする。検査と提示のみで実行はしない。Routine 互換。
argument-hint: "[--deep]"
disable-model-invocation: true
allowed-tools: Bash, Read, Grep
---

# health

`.agents/skills/health/SKILL.md` を Read し、ワークフロー手順に従う。

**重要:** 読み込んだスキル内の手順を忠実に実行する。section 順序、推奨アクション語彙、出力フォーマット（ステータス表・compact list）、エラーハンドリングは厳密に守る。

## Claude Code 固有の追加事項

### 引数解析

`--deep` フラグの有無を判定する:

- `--deep` あり → Phase 1 完了後に Phase 2（追加調査）を実行する
- `--deep` なし → Phase 1 のみ実行する（routine 互換）

`--deep` 以外のフラグは無視する（将来の拡張用）。

### 並列実行

16 領域のチェックコマンドは **同一メッセージ内に複数の Bash tool call** を並べることで並列実行する。直列に呼ばないこと。Phase 2 の追加調査も同様に **同一メッセージ内の複数 Bash tool call** で並列起動する。

### 完了報告・次のアクション提案

レポートを出力したら終了する。AskUserQuestion は使わない。次のアクション提案も行わない。ユーザーが推奨アクションを見て自ら判断・実行する。
