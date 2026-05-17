---
name: topics
description: GitHub topics 候補を制約検証・人気度測定・broad+narrow / 単数複数比較・ozzy-labs 慣行ハードコードで選定し、`gh repo edit --add-topic` で適用する。スコープは ozzy-labs 内利用のみ。
---

# topics - research-driven GitHub topics setup（ozzy-labs scope）

GitHub topics の選定は、毎リポで「候補列挙 → 人気度確認 → 公式制約 validation → 単数複数比較 → ozzy-labs 慣行と整合 → `gh repo edit --add-topic` 適用」の手作業を繰り返している。本スキルは選定段階の判断と適用段階の作業を一本化する。

**スコープ**: ozzy-labs 配下リポジトリの利用に限定する。クロス-org 汎用化・永続キャッシュ・他 org 用慣行は対象外（[スコープ外](#スコープ外)参照）。

## 入力

```text
topics <candidate-list>
  --repo owner/repo  (省略時は cwd の origin)
  --apply            (確認なしで gh repo edit を実行)
  --dry-run          (適用せず分析だけ)
```

- `<candidate-list>` は `,` 区切り、または複数引数
- `--apply` と `--dry-run` を同時指定した場合は `--dry-run` を優先する（誤適用防止）
- `--repo` 未指定時は `git remote get-url origin` から `owner/repo` を抽出する。GitHub remote が見つからない場合は中断する

## 手順

### Step 1: GitHub 公式制約 validation

GitHub topics の公式仕様に従って候補を篩い分ける（公式制約。Settings 画面でも同じ規則）:

| 制約 | 内容 |
| --- | --- |
| 文字種 | 半角 lowercase 英数字とハイフン `-` のみ（`a-z`, `0-9`, `-`） |
| 形式 | 先頭・末尾はハイフン不可 |
| 長さ | 最大 50 文字 |
| 個数 | 1 リポにつき最大 20 個 |

違反した候補は **除外して報告** する。除外理由を明示する（例: `Foo-Bar → 除外（uppercase 含む）`）。20 個超過時は重複排除後の上位を採用し、超過分を報告する。

### Step 2: 人気度取得（session 内キャッシュ）

各候補について GitHub Search API でリポジトリ件数を取得する:

```bash
gh api "search/repositories?q=topic:<name>" --jq .total_count
```

**session 内キャッシュ**: 同一 session で同じ topic を複数回問い合わせる場合（broad+narrow 比較・単数複数比較などで再利用）、初回値をメモして再呼出を抑止する。永続化はしない（[スコープ外](#スコープ外) 2 を参照）。

API 失敗時は当該候補のみ「人気度不明」と報告し、他候補の処理は継続する。判定上は `0` 扱いにせず、後続の 5x 比較や単数複数比較でも対象外とする。

### Step 3: broad+narrow 併記の閾値判定

候補内で意味的に重なる broad/narrow ペアを検出し、人気度比から推奨を決定する:

| 関係 | 推奨 |
| --- | --- |
| broad ≥ narrow × 5 | broad-only を推奨（narrow は冗長） |
| broad / narrow が同じオーダー（5 倍未満かつ broad のほうが多い） | 併記を推奨 |
| narrow > broad | ozzy-labs ハードコード例外として扱う（Step 5 を優先） |

**broad/narrow ペアの判定基準**: 候補リスト内で、片方が他方の prefix / 完全包含語であり、ハイフンで連結された派生語の関係にあるものを検出する（例: `ai` ⊃ `ai-agents`、`agent` ⊃ `multi-agent`）。完全一致ではない単純な共起（例: `news` と `release-notes`）は対象外。

### Step 4: 単数 / 複数の標準形比較

候補内に末尾 `-s` の付替えで意味が一致する組がある場合、両者の人気度を比較し優位な形を推奨する。

例:

- `agent` vs `agents` → 人気度の高い方を採用
- `topic` vs `topics`

Step 3 と重複する場合（`agent` ⊃ `multi-agent` のような派生語ペアではない単純な単数複数）、Step 4 のみ適用する。

### Step 5: ozzy-labs 慣行のハードコード

ozzy-labs リポ群で繰り返し採用してきた慣行をハードコードする。Step 3/4 の機械判定より優先する:

1. **`claude-code` は `claude` の上位扱いとして許容**: Anthropic の製品名 topic として `claude` 単独より優先度が高い。両者が候補にあれば併記を推奨する（broad+narrow 5x 例外。実測値 `claude-code` ≈ 25k vs `claude` ≈ 21k で narrow > broad の典型）
2. **`multi-agent` 形を採用、`multi-agents` / `multiagent` は除外**: ハイフン付き単数形に統一する
3. **`*-cli` サフィックス除去ルール**: `codex-cli`, `gemini-cli`, `copilot-cli` は `codex`, `gemini`, `copilot` に変換する。**例外**: `claude-code` は製品名（ハイフンが `cli` を意味しない）ため変換しない

ハードコードによる変換・除外は理由とともに報告する（例: `codex-cli → codex（*-cli サフィックス除去）`、`multiagent → 除外（multi-agent に統一）`）。

### Step 6: 出力と適用

#### 出力

```text
Candidates: 19
Filtered (constraints): 19/19 valid
Popularity:
  ai           120,879
  ai-agents     28,093
  claude-code   25,514  (>= claude × 1.2 — both retained per ozzy-labs convention)
  claude        21,062
  ...
Final 16 topics: ai, ai-agents, agentic, multi-agent, cli, claude, claude-code, codex, gemini, copilot, rss, web-scraping, news, release-notes, research, markdown
```

#### 適用

- `--dry-run` 指定時: 出力のみ、API 呼び出しなし
- `--apply` 指定時: 確認なしで `gh repo edit <owner/repo> --add-topic <topic1>,<topic2>,...` を実行
- どちらも未指定時: AskUserQuestion で適用可否を確認する（テキスト出力で `Apply? [Y/n]` のような選択肢を列挙しない）

適用後、結果を確認する:

```bash
gh repo view <owner/repo> --json repositoryTopics
```

期待値（適用候補）と実適用値の差分を最終レポートに含める。

## エラーハンドリング

| 状況 | 動作 |
| --- | --- |
| `gh` CLI が未認証 | エラーメッセージを表示して中断（GitHub Search API も失敗するため） |
| GitHub Search API rate limit / network error | 該当候補のみ「人気度不明」と報告し、他は継続。判定上は対象外（0 扱いにしない） |
| `--repo` 未指定で GitHub remote 不在 | 中断し、`--repo owner/repo` の明示を促す |
| 制約違反候補 100% | 「適用可能な候補なし」と報告し中断（API は呼ばない） |
| `gh repo edit --add-topic` 失敗 | 失敗 topic を列挙して中断（部分成功した topic は再表示する） |

## スコープ外

| 項目 | 除外理由 |
| --- | --- |
| 1. クロス-org 汎用化 | 現時点では ozzy-labs 専用。汎用化は別 issue で検討 |
| 2. 永続キャッシュ | session 内のみ。複数 session に跨る最適化は対象外 |
| 3. topics 適用部分の他リポ責務 | `commons/init-templates.sh` の `--topics` は「指定リストの適用」のみを担う。本スキルは選定支援、commons は適用、と責務を分離する。両者は人間オペレータ経由で連携する |

## 注意事項

- `.env` ファイルは読み取り・ステージングしない
- `gh` CLI が未認証の場合はエラーメッセージを表示して中断する
- ハードコードされた ozzy-labs 慣行（Step 5）は機械判定より優先する。例外を増やす場合は本スキル MD の改訂で行う（Claude の自由判断で慣行拡張しない）
- `--apply` は確認をスキップするため、必ず `--dry-run` で内容を確認した後に使う運用を推奨する
