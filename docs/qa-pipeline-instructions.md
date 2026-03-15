# QA統合パイプライン 構築指示書

> Claude Code への指示書  
> 目的：個人開発のFlutterプロジェクトに、OSSと無料ツールだけで「統合QAプラットフォーム」を構築する

---

## ゴール（完成形）

コードを `push` または PR をマージした瞬間に、人間が何も操作せず以下が自動実行される状態を作る。

```
Code Push / PR Merge
      ↓
① Unit & Widget テスト（flutter test）
      ↓
② API テスト（Postman CLI または Bruno）
      ↓
③ E2E テスト（integration_test または Maestro）
      ↓
④ 負荷テスト（k6）
      ↓
⑤ 全テスト結果を Allure Report に自動集約
      ↓
⑥ GitHub Pages に自動デプロイ（ダッシュボード化）
      ↓
⑦ Slack に品質スコアを通知
```

---

## 前提・制約

- **Flutter プロジェクト**（iOS + Web admin の構成）
- **すべて OSS または無料ツールのみ** を使用する（有料SaaSは使わない）
- **GitHub Actions** をパイプラインの基盤とする
- ローカル環境：Mac M2 / Windows 両対応を考慮すること

---

## やること（タスク一覧）

### STEP 1: プロジェクト構造の把握
- リポジトリのディレクトリ構成を確認する
- `pubspec.yaml` を読んで依存関係・Flutter バージョンを把握する
- 既存のテストファイル（`test/`, `integration_test/`）があれば確認する

### STEP 2: GitHub Actions ワークフローの作成
以下のファイルを作成する。

**`.github/workflows/qa-pipeline.yml`**

要件：
- `push` と `pull_request`（mainブランチ）でトリガー
- ジョブの実行順序：Unit → API → E2E → 負荷テスト（前のジョブが成功したら次へ）
- 各ジョブは失敗しても後続の集約ジョブは実行する（`if: always()`）
- Flutter のバージョンは `pubspec.yaml` から読み取って設定する

### STEP 3: 各テストの設定・動作確認

**Unit & Widget テスト**
- `flutter test --reporter json > test-results/unit-results.json` で結果をJSON出力
- Allure 用フォーマットへの変換を組み込む

**API テスト**
- `test/api/` ディレクトリを作成
- Bruno または Postman CLI でAPIテスト定義ファイルを作成（存在しない場合はサンプルを1件作る）
- CI 上で実行できるようにセットアップする

**E2E テスト**
- `integration_test/` 配下の既存ファイルを確認
- Maestro が使えるか確認。使えない場合は `flutter drive` で代替する
- 少なくとも1件の smoke test（アプリ起動確認）が動く状態にする

**負荷テスト（k6）**
- `test/load/` ディレクトリを作成
- `load_test.js` を1本作成（シンプルなHTTP GETのサンプルで可）
- CI 上での k6 実行設定を組み込む

### STEP 4: Allure Report のセットアップ

- 各テストの結果ファイル（JSON）を `allure-results/` に集約するステップを追加
- `allure generate` で静的レポートを生成
- GitHub Pages への自動デプロイを設定（`gh-pages` ブランチ）
- レポートURL を README に追記する

### STEP 5: Slack 通知の設定

**`.github/workflows/notify.yml`** または `qa-pipeline.yml` 内に追記

通知内容（テキスト形式で可）：
```
✅ QA Pipeline 完了
Branch: main | Commit: abc1234
Unit:  148/148 pass
API:   92/92 pass
E2E:   38/40 pass ⚠️
Load:  avg 187ms
📊 Report: https://[username].github.io/[repo]/
```

- Slack Webhook URL は `${{ secrets.SLACK_WEBHOOK_URL }}` で参照する
- シークレットの設定方法は README に手順を記載する

---

## 成果物（ファイル一覧）

作業完了後、以下のファイルが存在すること。

```
.github/
  workflows/
    qa-pipeline.yml       # メインパイプライン
test/
  api/
    sample.bru (or .json) # API テスト定義
  load/
    load_test.js          # k6 負荷テストスクリプト
integration_test/
  smoke_test.dart         # E2E スモークテスト（なければ新規作成）
README.md                 # セットアップ手順・レポートURLを追記
```

---

## 注意事項

- 既存のテストコードは**破壊しない**こと
- `pubspec.yaml` を書き換える場合は差分を明示すること
- シークレット（Slack Webhook等）は絶対にコードにハードコードしないこと
- 各ステップで「なぜその設定にしたか」をコメントとして yml 内に残すこと

---

## 参考：パイプライン完成後の確認ポイント

- [ ] PR を出したら自動で全テストが走るか
- [ ] GitHub Pages にレポートが反映されるか（URL が有効か）
- [ ] Slack に通知が来るか
- [ ] テストが1件失敗したとき、レポートに正しく反映されるか

---

*作成日: 2026-03-05 | 目的: Zenn 記事「個人開発で統合QAプラットフォームを作った話」の実証*
