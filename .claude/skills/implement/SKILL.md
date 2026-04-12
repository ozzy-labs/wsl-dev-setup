---
description: Issue または指示をもとに、ブランチ作成・実装を行う
argument-hint: "<#issue-number | instruction>"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# implement - Issue/指示からブランチ作成・実装

Issue 読解または直接指示をもとに、ブランチ作成・実装計画・コード変更までを行う。

## ワークフロー

### Step 1: 入力解析と要件把握

`$ARGUMENTS` を解析し、要件を特定する。

**Issue 番号の場合（`#N` または数字のみ）:**

1. `gh issue view <N>` で Issue の内容を取得する
2. タイトル・本文・ラベルから要件を整理する
3. 要件の理解をユーザーに提示して確認する

**テキスト指示の場合:**

- そのまま要件として扱う

**引数なしの場合:**

- AskUserQuestion で「何を実装しますか？（Issue 番号 or 説明）」と確認する（`answers` パラメータは設定しない）

**`gh` CLI エラー時:**

- 認証エラー: `gh auth login` の実行を案内して中断する
- Issue 未発見: Issue 番号を確認するよう案内して中断する

### Step 2: ブランチ作成

1. `git status` と `git branch --show-current` で現在の状態を確認する
2. 要件から `<type>/<slug>` 形式のブランチ名を決定する
3. `git checkout -b <branch-name>` でブランチを作成する

**既にフィーチャーブランチにいる場合:**

- そのブランチで作業を続けるか確認する

### Step 3: 実装計画

1. コードベースを調査する（Glob, Grep, Read）
   - 関連ファイルの特定
   - 既存の実装パターンの把握
   - 影響範囲の確認
2. 実装計画をユーザーに提示する:

```markdown
## 実装計画

### 変更内容
1. `path/to/file` — 変更の説明
2. `path/to/another` — 変更の説明

### 影響範囲
- 影響範囲の説明

承認しますか？
```

1. AskUserQuestion で確認（`answers` パラメータは設定しない）: 「この計画で実装」「計画を修正」「キャンセル」

**重要:** 承認なしにコード変更を開始しない。

### Step 4: 実装

承認された計画に従い、コード変更を実行する:

1. **コード変更:** Edit / Write ツールで実装する
2. **進捗報告:** 各ファイルの変更完了時に簡潔に報告する

実装中に計画の変更が必要になった場合は、ユーザーに相談する。

### Step 5: 動作確認

実装完了後、ユーザーに報告する**前に**必ず動作確認を行う。CLAUDE.md の「検証」セクションに記載されたコマンドを実行する。

**重要:** 動作確認でエラーが出た場合はその場で修正し、再度確認する。動作確認が全て通過してから次のステップに進む。

### Step 6: 完了報告＆次のアクション確認

実装完了を報告し、**同じレスポンス内で** AskUserQuestion を呼び出す。報告の出力だけでこのステップを終了しない。

報告フォーマット:

```text
実装完了:
  ブランチ: <branch-name>
  変更ファイル:
    A path/to/new-file
    M path/to/modified-file
```

報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）:

- **「lint・コミット・PR まで一括実行する」** → `.claude/skills/ship/SKILL.md` を Read し、その手順に従う
- **「個別に lint を実行する」** → `.claude/skills/lint/SKILL.md` を Read し、その手順に従う
- **「追加の変更を行う」** → 終了する

## 注意事項

- **.env ファイルは読み取り・ステージングしない**
- **`gh` CLI が未認証の場合はエラーメッセージを表示して中断する**
- **実装計画の承認なしにコード変更を開始しない**
