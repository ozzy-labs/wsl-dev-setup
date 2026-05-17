---
description: Phase-N tracking issue を生成する。引数で渡された項目はそのまま使い、不足分は AskUserQuestion で対話的に補う。`--draft` で stdout 出力、それ以外は `gh issue create` で起票する。
argument-hint: <phase-number> "<title>" [--description ...] [--refs ...] [--donts ...] [--decisions-file ...] [--tasks-file ...] [--dod ...] [--outlook ...] [--related ...] [--label ...] [--repo ...] [--draft]
disable-model-invocation: true
allowed-tools: Bash, Read, Write, AskUserQuestion
---

# phase-issue

`.agents/skills/phase-issue/SKILL.md` を Read し、ワークフロー手順に従う。

**重要:** 章立て・整形ルール・マーカーブロックは canonical SKILL.md の規約に厳密に従う。Claude の自由判断で章を増減しない。

## Claude Code 固有の追加事項

### 引数解析

`$ARGUMENTS` を解析する:

- `<phase-number>` と `<title>` が欠落している場合、AskUserQuestion でそれぞれ確認する（`answers` パラメータは設定しない）
- 任意オプション（`--description`, `--refs`, `--donts`, `--decisions-file`, `--tasks-file`, `--dod`, `--outlook`, `--related`, `--label`, `--repo`, `--draft`）は引数から取得する

### 不足項目の対話補完

引数で渡されなかった任意項目について、AskUserQuestion で **個別に** 補完するか確認する（`answers` パラメータは設定しない）。

質問順序（章立て順に従う）:

1. **「プロジェクト概要を入力する」** / 「省略する」 → `--description` 相当
2. **「参考実装を入力する」** / 「省略する」 → `--refs` 相当（カンマ区切り）
3. **「やってはいけないことを入力する」** / 「省略する」 → `--donts` 相当（改行区切り）
4. **「決定事項ファイルを指定する」** / 「TBD で残す」 → `--decisions-file` 相当
5. **「タスクファイルを指定する」** / 「TBD で残す」 → `--tasks-file` 相当
6. **「DoD を入力する」** / 「TBD で残す」 → `--dod` 相当（改行区切り）
7. **「Phase N+1 outlook を入力する」** / 「(未定) で残す」 → `--outlook` 相当
8. **「関連を入力する」** / 「省略する」 → `--related` 相当（改行区切り）

「入力する」を選んだ場合は AskUserQuestion で具体的な内容を尋ねる（自由記述は別の AskUserQuestion 呼び出しで行う）。

引数で既に渡された項目については **質問しない**（同じ情報を二重で集めない）。

### body プレビューと最終確認

body 組み立て後、起票または stdout 出力の前に、AskUserQuestion で確認する（`answers` パラメータは設定しない）:

- **「この内容で起票する」** → `gh issue create --body-file` で起票（`--draft` 指定時は stdout 出力）
- **「修正する」** → 修正対象セクションを尋ねて該当項目を再入力する
- **「キャンセル」** → 中断する

**重要:** 承認なしに `gh issue create` を実行しない。`--draft` モードでも、stdout 出力前に内容確認を行う。

### 完了後の次のアクション

完了報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）:

- **「この issue から `/drive` で実装を始める」** → 起票した issue 番号を引数として `/drive` を案内する（実行はしない）
- **「別の Phase issue を作成する」** → 本スキルを再度実行するよう案内する
- **「終了する」** → 終了する

ネクストアクションはユーザーの確認なく実行しない。
