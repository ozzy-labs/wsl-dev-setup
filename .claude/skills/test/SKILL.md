---
description: ビルド・テスト・型チェックを実行し、結果を報告する
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, AskUserQuestion
---

# test - ビルド・テストの実行

CLAUDE.md の「検証」セクションに記載されたコマンドを実行し、結果をレポートする。

## 手順

1. CLAUDE.md の「検証」セクションを Read し、実行すべきコマンドを特定する
2. 各コマンドを順に実行する
3. 全結果のサマリーを報告する

## 次のアクション提案（スキル完了後）

サマリー報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。報告の出力だけでスキルを終了しない。以下は基本選択肢であり、状況に応じて追加の選択肢を提示してよい:

**全て通過した場合:**

- **「コミットする」** → `.claude/skills/commit/SKILL.md` を Read し、その手順に従う
- **「PR を作成する」** → `.claude/skills/pr/SKILL.md` を Read し、その手順に従う
- **「コミット・PR まで一括実行する」** → `.claude/skills/ship/SKILL.md` を Read し、その手順に従う
- **「追加の変更を行う」** → 終了する

**失敗がある場合:**

- **「失敗を修正する」** → 修正完了後、手順 1 に戻って再実行する
- **「追加の変更を行う」** → 終了する
