# 駅掲示板 (my_first_app)

位置情報ベースの匿名駅掲示板アプリ。

## QA ステータス

[![QA Pipeline](https://github.com/hiroshisaito/my_first_app/actions/workflows/qa-pipeline.yml/badge.svg)](https://github.com/hiroshisaito/my_first_app/actions/workflows/qa-pipeline.yml)

📊 **Allure Report**: https://hiroshisaito.github.io/my_first_app/

---

## セットアップ

```bash
flutter pub get
flutter run
```

---

## テスト実行

```bash
# Unit & Widget テスト（全件）
flutter test

# E2E スモークテスト（Chrome が必要）
flutter test integration_test/smoke_test.dart -d chrome

# 負荷テスト（k6 が必要）
k6 run \
  --env SUPABASE_TEST_URL=https://xxx.supabase.co \
  --env SUPABASE_TEST_ANON_KEY=eyJ... \
  test/load/load_test.js
```

---

## QA パイプライン

`push` または `pull_request`（main ブランチ）をトリガーに以下が自動実行されます。

```
① Unit & Widget テスト  （flutter test）
② API テスト            （Bruno CLI）
③ E2E スモークテスト    （flutter test -d chrome）
④ 負荷テスト            （k6）
⑤ Allure Report 生成   → GitHub Pages へデプロイ
⑥ Slack へ結果通知
```

### GitHub Secrets の設定方法

Settings → Secrets and variables → Actions → New repository secret で以下を登録してください。

| Secret 名 | 内容 |
|-----------|------|
| `SUPABASE_TEST_URL` | テスト用 Supabase プロジェクトの URL（例: `https://xxx.supabase.co`） |
| `SUPABASE_TEST_ANON_KEY` | テスト用 Supabase の anon key |
| `SLACK_WEBHOOK_URL` | Slack Incoming Webhook URL |

> **注意**: `SUPABASE_TEST_URL` / `SUPABASE_TEST_ANON_KEY` は**本番とは別のテスト用プロジェクト**を用意してください。

### GitHub Pages の有効化

1. Settings → Pages を開く
2. Source: **Deploy from a branch**
3. Branch: `gh-pages` / `/(root)`
4. Save

### テスト用 Supabase プロジェクトの準備

1. [Supabase ダッシュボード](https://supabase.com) でテスト用プロジェクトを新規作成
2. `supabase/migrations/` のマイグレーション SQL を順番に適用
3. seed.sql を適用（k6 負荷テストが stations テーブルのデータを使用します）

---

## アーキテクチャ

```
lib/
├── screens/    → 画面（UIロジック）
├── widgets/    → 再利用可能UIコンポーネント
├── providers/  → Riverpod 状態管理
├── services/   → データ取得・外部通信
├── models/     → データモデル（イミュータブル）
└── design_system/ → テーマ・カラー・コンポーネント
```
