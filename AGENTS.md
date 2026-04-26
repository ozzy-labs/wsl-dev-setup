# AGENTS.md

このファイルは AI エージェント向けの共通 instructions です。

## 基本方針

- 日本語で応答する
- 推奨案とその理由を提示する
- `.env` ファイルは読み取り・ステージングしない
- 破壊的な Git 操作を避ける

## プロジェクト概要

`<project-name>`: <description>

## Tech Stack

- Runtime: Node.js (ESM)
- Package manager: pnpm
- Version management: mise (`.mise.toml`)

## 主要コマンド

```bash
pnpm install               # 依存関係インストール
pnpm run dev               # 開発サーバー起動
pnpm run build             # プロダクションビルド
```

## 検証（必須）

コード変更後、報告前に以下を通すこと:

1. `pnpm run build` — ビルド成功
2. `pnpm run typecheck` — 型チェック通過

## コーディング規約

- インデント: 2 スペース
- 改行コード: LF
- ファイル末尾: 改行あり

## 規約

言語・コミット・ブランチ・PR のルールは README.md を参照すること。

<!-- begin: @ozzylabs/skills -->

## Available Skills

- `commit` — 変更をステージし、Conventional Commits でコミットする。プッシュや PR 作成は行わない。
- `commit-conventions` — Conventional Commits のメッセージ生成ルール（Type/Scope 判定表、フォーマット）。他スキルから参照される。
- `drive` — Issue から実装・PR 作成・セルフレビュー・修正を自動で回し、merge-ready な PR を出す。Issue 番号またはテキスト指示を受け取る。オプションでマージまで実行可能。
- `implement` — Issue または指示をもとに、ブランチ作成・実装計画・コード変更を行う。Issue 番号またはテキスト指示を受け取る。
- `lint` — 全リンターを自動修正付きで実行し、結果を報告する。コード品質チェック、フォーマット、型チェック、セキュリティスキャンを含む。
- `lint-rules` — 拡張子別リンター・フォーマッターのコマンド対応表と型チェックルール。他スキルから参照される。
- `pr` — コミット済みの変更をリモートにプッシュし、PR を作成・更新する。
- `review` — コード変更や PR をレビューし、問題点・改善案を報告する。PR 番号または空（ワーキングツリー）を受け取る。
- `ship` — lint・コミット・PR 作成を一括実行する。変更に対して lint → コミット → PR 作成を順に実行する統合パイプライン。
- `test` — ビルド・テスト・型チェックを実行し、結果を報告する。

<!-- end: @ozzylabs/skills -->

## Adapter Files

| Agent | Configuration |
|-------|---------------|
| Claude Code | `CLAUDE.md`, `.claude/` |
| Gemini CLI | `.gemini/settings.json` → `AGENTS.md` |
| Codex CLI | `AGENTS.md` + `.agents/skills/` |
| GitHub Copilot | `AGENTS.md` + `.agents/skills/` |
