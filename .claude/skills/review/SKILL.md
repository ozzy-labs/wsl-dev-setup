---
description: コード変更や PR を 11 観点でレビューし、JSON 構造化出力 + 人間可読レポートで報告する。quick / deep モード対応。
argument-hint: <#PR-number | (blank for working tree changes)> [--axes=<axis,...>] [--deep]
disable-model-invocation: true
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Agent, AskUserQuestion
---

# review

`.agents/skills/review/SKILL.md` を Read し、ワークフロー手順に従う。

## Claude Code 固有の追加事項

### 引数解析

`$ARGUMENTS` を解析する:

- 数字または `#N` → PR 番号として扱う
- `--axes=<axis,...>` → 適用観点の明示指定
- `--deep` → deep モードで実行（観点ごとに `Agent({subagent_type: "code-reviewer"})` を **同一メッセージ複数 tool call** で並列起動する）

### deep モードでの並列起動

deep モードでは観点ごとに subagent を並列起動する。Claude Code 固有の `Agent` tool を使用する:

```text
Agent({
  subagent_type: "code-reviewer",
  prompt: "axis: <axis>\nmode: deep\ncontext:\n  base: <base>\n  head: <head>\n  pr_number: <N>\n\n<diff>"
})
```

- 同一 wave 内の独立 subagent は **1 メッセージ複数 tool call** で並列起動する
- 集約は呼び出し元（review skill 内の純スクリプト処理）で行う。LLM 呼び出しを追加しない
- subagent の戻り値（JSON）をマージし、`findings[]` に投入する

### 完了報告後

完了報告の直後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。

**指摘ありの場合:**

- **「指摘事項を修正する」** → Critical / Warning の指摘事項に基づきコードを修正する（Info は対象外）
- **「このまま進める」** → 終了する

**指摘なしの場合:**

- **「コミット・PR まで一括実行する」** → `.claude/skills/ship/SKILL.md` を Read し、その手順に従う
- **「このまま進める」** → 終了する
