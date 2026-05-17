---
name: review
description: コード変更や PR を 11 観点（perspectives）でレビューし、JSON 構造化出力 + 人間可読レポートで報告する。quick / deep モードを切替可能。PR 番号またはワーキングツリー差分を入力に取る。
---

# review - 多観点コードレビュー

差分を 11 観点（perspectives）でレビューし、Critical / Warning / Info に分類して JSON + 人間可読レポートで報告する。[ADR-0025](https://github.com/ozzy-labs/handbook/blob/main/adr/0025-skills-review-multi-perspective.md) の hybrid 方式（quick: 単一エージェント / deep: 観点並列サブエージェント）を採用する。

## 入力

- **PR 番号が指定された場合**（`#N` または数字のみ）:
  - `gh pr diff <N>` で差分を取得
  - `gh pr view <N>` で PR の説明を取得
- **引数なしの場合:**
  - `git diff` でワーキングツリーの変更を取得
  - 変更がなければ `git diff main...HEAD` でブランチ差分を取得
  - それでも変更がなければ、レビュー対象がない旨を伝えて終了する

## オプション

- `--axes=<axis,...>`: 適用観点を明示指定（自動選別を上書き、`default_enabled: false` 観点も明示時のみ有効化）
- `--deep`: deep モードで実行（観点ごとにサブエージェント並列起動。Claude Code 環境のみ。他アダプタでは quick にフォールバック）

## 観点（11 軸）

観点定義は `perspectives/<axis>.md` を SSOT とする。frontmatter で `category` / `applies_when` / `skip_when` / `default_enabled` / 検査項目 / severity ガイド / `exit_criteria.drive_loop` を宣言する。

| category | axis | 既定 |
| --- | --- | --- |
| required | correctness, security, conventions | 常に適用 |
| design | architecture, compatibility, maintainability | applies_when マッチ時 |
| quality | testing, performance, observability | applies_when マッチ時 |
| ux | usability, documentation | applies_when マッチ時 |

### 観点選別ロジック

`--axes` 未指定時は以下の順で適用観点を決定する:

1. `category: required` → 常に適用（`applies_when` / `skip_when` を無視）
2. `default_enabled: false` → `--axes` で明示指定された場合のみ適用（experimental 観点用、現状なし）
3. `skip_when.diff_only_in` がマッチ（全変更ファイルが指定 glob 集合の部分集合）→ 不適用（最優先のスキップ条件）
4. `applies_when` のいずれかの glob にマッチ → 適用（OR）
5. それ以外 → 不適用

`--axes=security,architecture` のように明示指定した場合は、その観点のみを適用する（`applies_when` / `skip_when` を無視）。

`skip_when` でサポートする初期キーは `diff_only_in` のみ。未定義キーは reader が無視する（forward-compat）。

## 手順

### 1. 適用観点の決定

1. 差分から変更ファイル一覧を抽出する
2. `perspectives/` 配下の全観点 MD を Read し、frontmatter を解釈する
3. 上記の観点選別ロジックで適用観点リストを決定する
4. 適用観点リストを最初に表示する:

```text
適用観点 (5/11):
  required: correctness, security, conventions
  design:   architecture
  ux:       documentation
```

### 2. レビュー実施

#### quick モード（デフォルト）

単一エージェントが適用観点を順に走査する。各観点について:

1. 該当 `perspectives/<axis>.md` を Read（既に読み込み済みの場合は省略）
2. 検査項目・severity ガイドに従って差分をレビュー
3. findings を内部 JSON バッファに追加

すべての観点を走査し終えたら集約に進む。

#### deep モード（`--deep`）

観点ごとに `Agent({subagent_type: "code-reviewer"})` を **並列起動** する。各 subagent は対応する `perspectives/<axis>.md` を Read し、JSON で findings を返す。

呼び出しプロンプトの形式:

```text
axis: <axis-name>
mode: deep
context:
  base: <base-ref>
  head: <head-ref>
  pr_number: <N (optional)>

<diff>
```

並列起動は **1 メッセージ複数 tool call** で行う。subagent からは slash command を呼べないため、観点 MD の Read と JSON 出力のみで完結させる。

deep モードは Claude Code 環境のみで利用可能。他アダプタ（codex-cli / gemini-cli）では quick にフォールバックする（adapter 別の挙動は `SKILL.<adapter>.md` で吸収）。

### 3. 集約

#### 重複統合

- 同一 `file:line` に複数観点が同じ issue を出した場合、1 件に統合し `axes` を併記する
- 同一 `file:line` で観点が異なるが issue 文言が同じ場合（例: security と correctness が両方「未サニタイズ入力」を指摘）も統合対象

#### 観点間衝突

- 原理的トレードオフ（例: security ↔ DX、observability ↔ performance）は **conflicts セクション** に別記し、severity を付けず判断委ねとする

#### グルーピング

レポートは「観点 → severity → ファイル」順でグループ化する。

### 4. JSON 構造化出力

内部表現は **必ず JSON**。findings はすべて JSON で保持し、PR コメント・標準出力は JSON からレンダラを通して人間可読フォーマットに変換する。

#### Schema (version "1")

```json
{
  "version": "1",
  "mode": "quick" | "deep",
  "axes_applied": ["security", "correctness", "..."],
  "findings": [
    {
      "axis": "security",
      "severity": "critical" | "warning" | "info",
      "file": "src/x.ts",
      "line": 42,
      "issue": "...",
      "why": "...",
      "suggestion": "...",
      "axes_merged": ["security", "correctness"]
    }
  ],
  "conflicts": [
    {
      "axes": ["security", "usability"],
      "file": "src/y.ts",
      "line": 10,
      "description": "..."
    }
  ],
  "summary": {
    "by_axis": {
      "security": {"critical": 0, "warning": 1, "info": 0}
    },
    "total": {"critical": 0, "warning": 1, "info": 3}
  }
}
```

`axes_merged` と `conflicts` は任意フィールド（重複統合・観点間衝突がある場合のみ）。

#### Version migration policy

- `version` は単調増加の整数（文字列）。本 ADR で `"1"` を確立する
- reader 側（drive など）は `version` が現状コードの上限と一致する場合のみ機械判定を行う
- 未対応 version の場合は `unknown_review_version` として fail-soft 終了し、JSON を無視して人間可読部分のみ扱う
- 互換破壊変更は `version` を bump し、reader は最低 N-1 まで読める実装を維持する

### 5. レポート出力

#### 人間可読フォーマット

```text
レビュー結果 (mode: <quick|deep>, axes: <list>):

## correctness
[Critical] src/foo.ts:42
  問題: <issue>
  理由: <why>
  提案: <suggestion>

## security
[Warning] .github/workflows/release.yaml:10
  問題: ...

...

## conflicts
[security ↔ usability] src/y.ts:10
  <description>

## サマリー
  Critical: N 件
  Warning:  N 件
  Info:     N 件

  by_axis:
    correctness:    C0 W0 I1
    security:       C0 W1 I0
    ...
```

#### PR コメントへの埋め込み（PR レビュー時）

人間可読レポートの末尾に JSON を **HTML コメント** として埋め込む（drive がこれを再読する）:

```markdown
... 人間可読レポート ...

<!-- review-json:v1
{
  "version": "1",
  ...
}
-->
```

PR レビューの場合、レポート全体を `gh pr comment <N> --body "<レポート>"` で PR にコメントとして投稿する。

### 6. 過去 PR コメントとの互換（resume）

drive が過去に投稿したコメントには JSON 埋込みがない場合がある。reader は次のように扱う:

- `<!-- review-json:v1 ... -->` を含むコメント → JSON を解析して機械判定
- JSON 不在のコメント → **legacy comment** として扱い、新規 review pass の trigger として無視する（過去コメントは消さない）
- `<!-- review-json:v<unknown> ... -->` → `unknown_review_version` として無視（fail-soft）

## 注意事項

- `Critical` を 1 件でも報告する場合は明確な悪影響（バグ・脆弱性等）の根拠を示す
- 観点の severity 判定は対応する `perspectives/<axis>.md` の severity ガイドに従う。観点を超えて勝手に重要度を上げ下げしない
- deep モードは観点数 × 並列度ぶんのトークンを消費する。drive のオーケストレーションモードでは強制的に quick にフォールバック（コスト管理）
- `Info` は提案のみ。drive の review loop では `Info` を修正対象としない
