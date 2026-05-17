---
name: phase-issue
description: Phase-N tracking issue を生成する。cross-session handoff context、決定事項表、PR ごとのタスク、DoD、Phase N+1 outlook を含む構造化された issue body を組み立てて gh issue create で起票する。引数で全項目を渡す非対話モードと、不足分を補う対話モード（Claude Code companion）に対応する。
---

# phase-issue - Phase-N tracking issue 生成

ozzy-labs で繰り返し発生する Phase-N tracking issue（cross-session handoff context + 決定事項表 + PR ごとのタスク + DoD + Phase N+1 outlook）の構造をハードコードし、引数または対話で集めた内容から決定論的に issue body を組み立てる。`gh issue create --body-file` で起票するか、`--draft` 指定時は stdout に出力する。

このスキル単体で起票まで完結する。drive 連携や Phase 番号の自動採番は行わない（スコープ外）。

## 入力

```text
phase-issue <phase-number> "<title>"
  --description "..."         (project description; プロジェクト概要)
  --refs "owner/repo1,owner/repo2"  (参考実装。カンマ区切り)
  --donts "..."               (やってはいけないこと。改行区切り)
  --decisions-file <path>     (決定事項 YAML/Markdown ファイル)
  --tasks-file <path>         (PR ごとのタスクファイル)
  --dod "..."                 (Definition of Done。改行区切り)
  --outlook "..."             (Phase N+1 outlook)
  --related "..."             (関連 issue/PR/ADR。改行区切り)
  --label "<label>"           (issue label。既定: "chore")
  --repo "<owner/repo>"       (起票先リポ。省略時はカレントリポ)
  --draft                     (起票せず stdout に body を出力)
```

### 必須引数

- `<phase-number>`: 整数（例: `0`, `1`, `2`）
- `<title>`: 引用符でくくった文字列（例: `"agentic-watch foundation"`）

### 任意引数の取り扱い（非対話モード）

canonical SKILL.md は **非対話前提** で動作する。任意引数が不足している場合、対応するセクションは body から **省略**する（プレースホルダーでは埋めない）。「不明分は対話で集めたい」場合は Claude Code companion（`SKILL.claude-code.md`）を使う。

`--decisions-file` および `--tasks-file` が指定された場合、ファイル内容をそのまま該当セクションに転記する（解析・整形はしない。ユーザー側で markdown 整形済みであることを期待する）。

## ハードコードされた章立て

issue body は以下の章立てで構築する。**順序は固定**で、変更しない:

```markdown
# Phase {{N}}: {{title}}

## Cross-session handoff

このセクションは新しいセッション/エージェントが本 issue を読んだだけで作業を引き継げるよう、必要な context を集約する。

- **プロジェクト概要:** {{description}}
- **参考実装:** {{refs (linked)}}
- **やってはいけないこと:** {{donts (bulleted)}}

## 決定事項

{{decisions-file の内容、または "(TBD)"}}

## タスク（PR ごと）

{{tasks-file の内容、または "(TBD)"}}

## Definition of Done

{{dod (bulleted)}}

## Phase {{N+1}} outlook

{{outlook、または "(未定)"}}

## 関連

{{related (bulleted)}}
```

### セクションごとの整形ルール

- **Cross-session handoff:**
  - `--description` がない場合は `(未記入)` ではなく **行ごと省略**（bulleted item を出さない）
  - `--refs` はカンマ区切りを bulleted list に展開し、`owner/repo` は `https://github.com/owner/repo` に linkify する
  - `--donts` は改行区切りを bulleted list に展開する
  - 3 項目すべてが空の場合、`## Cross-session handoff` セクション自体を省略する
- **決定事項 / タスク（PR ごと）:** ファイルが指定されない場合、セクション本文を `(TBD)` とする（セクション自体は残す）。Phase issue で **決定事項とタスクは骨格** に当たるため、未記入でもプレースホルダーを残して後追いを促す
- **DoD:** 改行区切りを `- [ ] item` 形式の checkbox list に展開する。空の場合 `(TBD)` とする
- **Phase N+1 outlook:** 文字列をそのまま転記する。空の場合 `(未定)` とする
- **関連:** 改行区切りを bulleted list に展開する。`#N` / `owner/repo#N` / URL いずれも許容（linkify はせず原文を保持）。空の場合セクションを省略する

### マーカーブロック注記

cross-session handoff の冒頭に以下の HTML コメントを必ず埋め込む。これは将来 phase-issue で再生成・更新する際の anchor として機能する:

```markdown
<!-- phase-issue:v1 phase=N -->
```

`v1` は本スキルが生成する body のフォーマットバージョン。schema を変える場合は bump する。

## 手順

### 1. 引数解析

1. `<phase-number>` と `<title>` を取得する。どちらも必須。欠落時はエラーを表示して中断する
2. オプションを解析する。同じオプションが複数回指定された場合は最後のものを採用する
3. `--decisions-file` / `--tasks-file` が指定された場合、ファイルの存在と読み取り可否を確認する。失敗時はエラーを表示して中断する

### 2. body 組み立て

1. ハードコードされた章立てに従って body を組み立てる
2. プレースホルダー `{{N}}` / `{{title}}` / `{{N+1}}` を実値で置換する
3. 各セクションの整形ルールに従い、空セクションは省略 / TBD / 未定 を適切に出し分ける
4. マーカーブロックを cross-session handoff の冒頭に挿入する

### 3. 起票または stdout 出力

- `--draft` 指定時:
  - body を stdout に出力する
  - `gh` コマンドは呼び出さない
- `--draft` 未指定時:
  - body を一時ファイルに書き出す
  - `gh issue create --title "Phase {{N}}: {{title}}" --label "<label>" --body-file <tmp>` を実行する
  - `--repo` が指定されていれば `--repo` 引数を gh に渡す
  - 起票成功時は issue URL を表示する

### 4. 完了報告

```text
phase-issue 完了:
  タイトル: Phase <N>: <title>
  起票先:    <repo>
  Issue:    <URL>  (--draft 指定時は "(stdout に出力)")
```

## 注意事項

- 引数で渡されない任意項目は body から省略するか TBD で埋める。Claude が想像で内容を補完しない
- `gh` CLI が未認証の場合はエラーメッセージを表示して中断する
- `--draft` モードでは外部副作用なし（ファイル書き込みも `gh` 呼び出しもない）
- title は double quote でくくる前提。コマンド側のシェルエスケープは呼び出し元の責任
- canonical SKILL.md は非対話前提。対話的に項目を集めたい場合は Claude Code companion を使う
- **過去 issue からの style 学習はしない**: 章立ては SKILL.md 内に固定する（学習機構は実装複雑度に対し対価が小さい）
- **Phase 番号の自動採番はしない**: `<phase-number>` は呼び出し元が明示する
- **drive 連携はしない**: phase-issue は起票で完結する。生成された issue の分割・実装は別途 drive で回す
