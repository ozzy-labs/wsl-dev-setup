---
description: lint・コミット・PR 作成を一括実行する
disable-model-invocation: true
allowed-tools: Bash, Read, Grep, Glob, AskUserQuestion
---

# ship - lint・コミット・PR を一括実行

変更に対して lint → コミット → PR 作成を順に実行する統合パイプライン。

いずれかのステップで失敗した場合は中断し、エラー内容を報告する。

**重要:** 各ステップの SKILL.md を Read して**ワークフロー手順のみ**を実行する。読み込んだ SKILL.md 内の「次のアクション提案」セクションおよび「完了報告」セクションは**すべて無視**する。ステップ間の遷移は本スキルが制御する。

## ワークフロー

### Step 1: lint

`.claude/skills/lint/SKILL.md` を Read し、その手順に従って全リンター・フォーマッターを実行する。

**失敗した場合:** エラー内容を報告し、修正→再度 `/ship` を提案して中断する。

### Step 2: commit

`.claude/skills/commit/SKILL.md` を Read し、ステージング＆コミットの手順に従う。

**変更がない場合:** 既にコミット済みの未プッシュコミットがあれば Step 3 に進む。なければ終了する。

### Step 3: pr

`.claude/skills/pr/SKILL.md` を Read し、プッシュ＆PR 作成の手順に従う。

### Step 4: 完了報告

実行結果をまとめて報告する:

```text
完了:
  コミット: abc1234 feat: add blog post
  ブランチ: feat/add-blog
  PR: <PR URL>
```

### Step 5: 次のアクション提案

AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。以下の選択肢を表示する:

- **「PR をレビューする」** → `.claude/skills/review/SKILL.md` を Read し、その手順に従う
- **「PR をマージする」** → `gh pr merge --squash --delete-branch` でマージを実行し、結果を報告する
