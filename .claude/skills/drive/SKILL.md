---
description: Issue から実装・PR 作成・セルフレビュー・修正を自動で回し、merge-ready な PR を出す
argument-hint: "<#issue-number | instruction>"
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebSearch, WebFetch, AskUserQuestion
---

# drive - Issue から merge-ready な PR まで自律駆動

Issue または指示を受け取り、実装 → ship → セルフレビュー → 修正を自動で繰り返して merge-ready な PR を作成する。マージはユーザーの明示的な指示まで行わない。

**重要:** 各フェーズでは対応するスキルの SKILL.md を Read して**ワークフロー手順のみ**を実行する。読み込んだ SKILL.md 内の「次のアクション提案」セクションおよび「完了報告」セクションは**すべて無視**する。フェーズ間の遷移は本スキルが制御する。

## ワークフロー

### Phase 1: implement

`.claude/skills/implement/SKILL.md` を Read し、ワークフローを実行する。ただし以下の点が異なる:

- **計画承認をスキップ:** `/drive` を実行した時点でユーザーは自律実行を委任しているため、計画を自ら承認して実装を進める
- **完了報告・次のアクション確認は無視:** フェーズ間の遷移は本スキルが制御する

**中断条件:**

- 動作確認が繰り返し失敗する場合 → エラーを報告して中断

implement が完了したら、ユーザー確認なしに Phase 2 に進む。

### Phase 2: ship

`.claude/skills/ship/SKILL.md` を Read し、lint → commit → PR 作成を実行する。完了報告・次のアクション確認は無視する。

- PR 番号を記録する（Phase 3 で使用）

**中断条件:**

- lint が失敗し、自動修正できない場合 → エラーを報告して中断

ship が完了したら、ユーザー確認なしに Phase 3 に進む。

### Phase 3: review loop（最大 3 回）

以下のループを最大 3 回繰り返す:

#### 3a. レビュー実行

`.claude/skills/review/SKILL.md` を Read し、レビューワークフローを実行する。次のアクション確認は無視する。

- 対象: Phase 2 で作成した PR 番号
- レビュー結果を PR コメントとして投稿する

#### 3b. 判定

レビュー結果に基づいて次のアクションを決定する:

- **Critical または Warning が 0 件** → ループを終了し、Phase 4 に進む
- **Critical または Warning がある場合** → 3c に進む
- **ループ上限（3 回）に到達** → ループを終了し、Phase 4 に進む（残存指摘を報告に含める）

#### 3c. 修正

Critical および Warning の指摘事項のみを修正する。**Info は修正しない**（報告のみ）。

修正後、lint → commit → push を実行し、3a に戻る。

### Phase 4: 完了報告

全フェーズの結果をまとめて報告する:

```text
/drive 完了:
  Issue:    #<number> <title>
  ブランチ: <branch-name>
  PR:       <PR URL>
  レビュー: N 回実施（Critical: 0, Warning: 0, Info: N）
  状態:     merge-ready
```

### Phase 5: 次のアクション確認

AskUserQuestion を呼び出す（`answers` パラメータは設定しない）。以下の選択肢を表示する:

- **「PR をマージする」** → `gh pr merge --squash --delete-branch` でマージを実行し、結果を報告する
- **「追加の変更を行う」** → 終了する

## 中断時の振る舞い

いずれかのフェーズで中断した場合:

1. どのフェーズで中断したかを明示する
2. エラー内容を報告する
3. AskUserQuestion で次のアクションを確認する:
   - **「エラーを修正して再開する」** → 中断したフェーズから再開
   - **「中断する」** → 終了

## 注意事項

- **.env ファイルは読み取り・ステージングしない**
- **`gh` CLI が未認証の場合はエラーメッセージを表示して中断する**
- **計画承認を含め、マージ前まで AskUserQuestion を使用しない**（完全自律実行）
- **マージはユーザーの明示的な指示がない限り実行しない**
- **Info 指摘は修正せず報告のみ**（設計判断に関わる変更を機械的に行わない）
