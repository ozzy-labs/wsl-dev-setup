---
description: GitHub topics 候補を制約検証・人気度測定・broad+narrow / 単数複数比較・ozzy-labs 慣行で選定し適用する。スコープは ozzy-labs 内利用のみ。
argument-hint: "<candidate-list> [--repo owner/repo] [--apply | --dry-run]"
disable-model-invocation: true
allowed-tools: Bash, Read, AskUserQuestion
---

# topics

`.agents/skills/topics/SKILL.md` を Read し、ワークフロー手順に従う。

**重要:** 公式制約 validation（lowercase / hyphen / 50 chars / max 20）、session 内キャッシュ、broad+narrow 5x 比較、単数/複数比較、ozzy-labs 慣行のハードコード（`claude-code` 例外、`*-cli` 除去ルール、`multi-agent` 形固定）はすべて忠実に実行する。

## Claude Code 固有の追加事項

### 引数解析

- `<candidate-list>`: `,` 区切り or 複数引数
- `--repo owner/repo`: 省略時は `git remote get-url origin` から抽出
- `--apply`: 確認なしで `gh repo edit --add-topic` を実行
- `--dry-run`: 適用せず分析のみ
- `--apply` と `--dry-run` 同時指定時は `--dry-run` を優先する

### 適用確認

`--apply` / `--dry-run` どちらも未指定の場合、最終 topics リストを提示した後に AskUserQuestion を呼び出す（`answers` パラメータは設定しない）:

- **「適用する」** → `gh repo edit --add-topic` を実行する
- **「適用しない」** → 分析結果のみ表示して終了する
- **「候補を編集する」** → 終了し、ユーザーに再実行を促す

### 完了報告・次のアクション提案

適用結果（または dry-run 結果）を表示したら終了する。次のアクション提案は行わない。
