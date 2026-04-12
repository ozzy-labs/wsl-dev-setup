---
description: 全リンターを自動修正付きで実行し、結果を報告する
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, AskUserQuestion
---

# lint - 全リンターの実行

全リンター・フォーマッターを自動修正付きで実行し、結果をレポートする。

## 手順

1. `git status` で変更ファイルを特定する。変更がなければプロジェクト全体を対象とする
2. `.claude/skills/lint-rules/SKILL.md` を Read し、コマンド表と型チェックルールに従って対象ファイルの lint・フォーマット・型チェックを実行する
3. 全結果のサマリーを報告する

## 次のアクション提案（スキル完了後）

サマリー報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。報告の出力だけでスキルを終了しない。以下は基本選択肢であり、状況に応じて追加の選択肢を提示してよい:

**全て通過した場合:**

- **「コミットする」** → `.claude/skills/commit/SKILL.md` を Read し、その手順に従う
- **「コミット・PR まで一括実行する」** → `.claude/skills/ship/SKILL.md` を Read し、その手順に従う
- **「追加の変更を行う」** → 終了する

**エラーがある場合:**

- **「エラーを修正する」** → 修正完了後、手順 1 に戻って再実行する
- **「追加の変更を行う」** → 終了する
