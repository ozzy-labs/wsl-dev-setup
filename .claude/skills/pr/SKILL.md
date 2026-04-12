---
description: 変更を push し、PR を作成・更新する
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion
---

# pr - プッシュ＆PR 作成

コミット済みの変更をリモートにプッシュし、PR を作成・更新する。

**このスキルは PR の作成までを行う。** レビューは完了後のネクストアクションとして提示する。

## ワークフロー

### Step 1: 状態確認

以下のコマンドで現在の状態を把握する:

- `git branch --show-current` で現在のブランチを確認
- `git status` で未コミットの変更を確認
- `git log --oneline origin/<branch>..HEAD 2>/dev/null || git log --oneline -5` で未プッシュのコミットを確認

**main ブランチの場合:** main ブランチから直接 push すべきでない旨を警告し、`/implement` でフィーチャーブランチを作成するか、手動で `git checkout -b <branch>` するよう案内して終了する。

**未コミットの変更がある場合:** 先に `/commit` でコミットするよう案内して終了する。

**プッシュ対象がない場合:** プッシュするコミットがない旨を伝えて終了する。

### Step 2: プッシュ＆PR 作成

1. `git push -u origin <branch>` でリモートにプッシュする
2. PR の作成:
   - `gh pr view` で既存 PR を確認する
   - **既存 PR がない場合:** `gh pr create --title "<タイトル>" --body "<本文>"` で PR を作成する。タイトルは直近のコミットメッセージの1行目を使用する
   - **既存 PR がある場合:** プッシュのみ（PR は自動更新される）
3. PR の URL をユーザーに報告する

PR の本文フォーマット:

```markdown
## Summary

- <変更内容の箇条書き>

Closes #N <!-- Issue 起点の場合のみ -->
```

### Step 3: 完了報告

実行結果をまとめて報告する:

```text
完了:
  ブランチ: <branch-name>
  PR: <PR URL>
```

### Step 4: 次のアクション提案

AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。以下の選択肢を表示する:

- **「PR をレビューする」** → `.claude/skills/review/SKILL.md` を Read し、その手順に従う
- **「PR をマージする」** → `gh pr merge --squash --delete-branch` でマージを実行し、結果を報告する
