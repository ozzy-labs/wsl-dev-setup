---
description: 変更をステージし、Conventional Commits でコミットする（push はしない）
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion
---

# commit - ステージング＆コミット

変更をステージし、Conventional Commits でコミットする。プッシュや PR 作成は行わない。

## ワークフロー

### Step 1: 状態確認

以下のコマンドで現在の状態を把握する:

- `git status` で変更ファイルの一覧を取得
- `git diff` でステージされていない変更を確認
- `git diff --staged` でステージ済みの変更を確認
- `git log --oneline -5` で直近のコミット履歴を確認

**変更がない場合:** コミットする変更がない旨を伝えて終了する。

変更ファイルの一覧をユーザーに提示する:

```text
変更ファイル:
  M src/pages/index.astro
  A src/content/blog/new-post.md
```

### Step 2: ステージング＆コミット

1. **ステージング:** 変更ファイルを個別に `git add <file>` でステージする。`.env` ファイルはステージングしない
2. **コミットメッセージ生成:** `.claude/skills/commit-conventions/SKILL.md` を Read し、ルールに従いメッセージを生成する
3. **コミット実行:** `git commit -m "<message>"`
   - lefthook の commit-msg フック（commitlint）と pre-commit フック（各リンター）が自動実行される

### Step 3: 完了報告

実行結果を報告する:

```text
完了:
  コミット: abc1234 feat: add blog post
```

## 次のアクション提案（スキル完了後）

完了報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。報告の出力だけでスキルを終了しない。以下は基本選択肢であり、状況に応じて追加の選択肢を提示してよい:

- **「PR を作成する」** → `.claude/skills/pr/SKILL.md` を Read し、その手順に従う
- **「追加の変更を行う」** → 終了する
