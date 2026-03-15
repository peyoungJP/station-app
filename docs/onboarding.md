# プロジェクト引き継ぎドキュメント

> このドキュメントは、このプロジェクトを初めて触る人が「今日から開発できる」状態になることを目的としています。
> 疑問に思ったことはすべてここに答えがあるはずです。なければ CLAUDE.md や他のdocsを参照してください。

---

## 目次

1. [このアプリとは何か](#1-このアプリとは何か)
2. [開発環境のセットアップ](#2-開発環境のセットアップ)
3. [技術スタック](#3-技術スタック)
4. [コードベースの全体構造](#4-コードベースの全体構造)
5. [アーキテクチャのルール](#5-アーキテクチャのルール)
6. [データの流れを追う](#6-データの流れを追う)
7. [モックモードと本番モード](#7-モックモードと本番モード)
8. [よく使うコマンド集](#8-よく使うコマンド集)
9. [機能を追加するときの手順](#9-機能を追加するときの手順)
10. [テストの書き方](#10-テストの書き方)
11. [デザインシステムの使い方](#11-デザインシステムの使い方)
12. [事業の現在地と今後の計画](#12-事業の現在地と今後の計画)
13. [やってはいけないこと](#13-やってはいけないこと)
14. [困ったときの調べ方](#14-困ったときの調べ方)

---

## 1. このアプリとは何か

### 一言で言うと

**「今いる駅の匿名掲示板アプリ」**

GPSで現在地を取得し、近くの駅の掲示板（スレッド一覧）を自動表示します。
ユーザー登録なし・完全匿名で、誰でも書き込めます。

### 解決する問題

| 場面 | 問題 | このアプリの解決策 |
|------|------|--------------------|
| 電車が遅延した | Xで検索しても情報がバラバラ | 駅ごとにスレッドがまとまっている |
| 新しい駅を使い始めた | 周辺情報がわからない | 同じ駅を使う人の声がリアルタイムで見れる |
| 通報したい書き込みがある | ─ | 通報機能がある |

### 現在のアプリ画面構成

```
HomeScreen（ホーム）
  ↓ 駅をタップ
BoardScreen（掲示板 = スレッド一覧）
  ↓ スレッドをタップ
ThreadDetailScreen（スレッド詳細 + 返信一覧）
  ↓ FABをタップ（BoardScreenのFABから）
CreateThreadScreen（スレッド作成）

HomeScreen の右上アイコン
  ↓
SettingsScreen（設定）
  ↓ メニューをタップ
LegalScreen（利用規約・プライバシーポリシー）
```

---

## 2. 開発環境のセットアップ

### 前提条件（インストール済みであること）

- Flutter SDK（3.x 以上）
- Dart SDK（Flutter に同梱）
- iOS シミュレーター or Android エミュレーター
- VS Code（推奨）または Android Studio

### 手順

**1. リポジトリをクローン**

```bash
git clone <リポジトリURL>
cd my_first_app
```

**2. パッケージをインストール**

```bash
flutter pub get
```

**3. モックモードでアプリを起動する（Supabase接続なしで動作確認）**

```bash
flutter run
```

環境変数 `SUPABASE_URL` が設定されていなければ、自動的にモックモードで起動します。
モックモードでは全データが擬似データになります（後述）。

**4. テストを実行して全件 pass することを確認**

```bash
flutter test
```

すべて green になれば環境構築完了です。

### Supabase に接続する場合（本番・ステージング）

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci...
```

環境変数は `.env` ファイルや CI の secrets に保存してください。
**絶対にソースコードにハードコードしないこと。**

---

## 3. 技術スタック

| 技術 | バージョン | 役割 | 選定理由 |
|------|-----------|------|---------|
| Flutter | 3.x | UIフレームワーク | iOS/Android を1つのコードベースで開発 |
| Dart | 3.x | 言語 | Flutter の言語 |
| flutter_riverpod | ^2.6.1 | 状態管理 | Provider の進化版。テストしやすい |
| Supabase | ^2.8.0 | バックエンド | DB + API + Auth をまとめて提供 |
| geolocator | ^13.0.2 | 位置情報 | GPS取得・権限管理 |
| intl | ^0.20.2 | 日付フォーマット | "XX分前" などの表示 |
| google_fonts | ^6.2.1 | フォント | Zen Maru Gothic（日本語）等 |

### Riverpod について（最重要）

Riverpod は状態管理ライブラリです。よく使うパターンは2つです。

**Provider（サービスの依存注入）**

```dart
// サービスをどこからでも取得できるようにする
final threadServiceProvider = Provider((ref) => ThreadService());

// 使う側（providers層）
final service = ref.read(threadServiceProvider);
```

**AsyncNotifierProvider（非同期データ管理）**

```dart
// データの状態を AsyncValue<T> で管理（loading / data / error の3状態）
final threadsProvider = AsyncNotifierProvider.family<ThreadsNotifier, List<Thread>, String>(
  ThreadsNotifier.new
);

// 使う側（screens層）
final state = ref.watch(threadsProvider(stationId));
state.when(
  loading: () => CircularProgressIndicator(),
  data: (threads) => ListView(...),
  error: (e, st) => ErrorView(error: e),
);
```

---

## 4. コードベースの全体構造

```
my_first_app/
├── lib/                          # アプリのソースコード
│   ├── main.dart                 # エントリーポイント
│   ├── design_system/            # デザイン共通部品
│   │   ├── tokens.dart           # 色・余白・角丸の定数
│   │   ├── theme.dart            # Material 3 テーマ設定
│   │   └── components.dart       # AppButton, AppCard など汎用ウィジェット
│   ├── models/                   # データモデル（Plain なデータクラス）
│   │   ├── location.dart         # 駅・イベント・エリア
│   │   ├── thread.dart           # スレッド
│   │   ├── post.dart             # 返信投稿
│   │   └── report.dart           # 通報
│   ├── services/                 # データ取得・外部通信
│   │   ├── supabase_service.dart # Supabase クライアント初期化
│   │   ├── location_service.dart # GPS取得
│   │   ├── nearby_location_service.dart # 近隣駅・イベント取得
│   │   ├── thread_service.dart   # スレッドCRUD
│   │   ├── post_service.dart     # 投稿CRUD
│   │   └── report_service.dart   # 通報送信
│   ├── providers/                # Riverpod 状態管理
│   │   ├── location_provider.dart         # 現在地
│   │   ├── nearby_location_provider.dart  # 近隣駅一覧
│   │   └── thread_provider.dart           # スレッド・投稿
│   ├── screens/                  # 画面
│   │   ├── home_screen.dart
│   │   ├── board_screen.dart
│   │   ├── thread_detail_screen.dart
│   │   ├── create_thread_screen.dart
│   │   ├── settings_screen.dart
│   │   └── legal_screen.dart
│   ├── widgets/                  # 再利用可能なUIパーツ
│   │   ├── location_card.dart    # 駅カード
│   │   ├── thread_card.dart      # スレッドカード
│   │   ├── post_item.dart        # 返信1件分
│   │   └── error_view.dart       # エラー表示
│   └── utils/                    # ユーティリティ
│       ├── input_sanitizer.dart  # HTMLタグ除去など
│       └── ng_word_filter.dart   # NGワードチェック
├── test/                         # テストコード
│   ├── helpers/                  # テスト用共通部品
│   │   ├── fixtures.dart         # テストデータの工場
│   │   ├── test_app.dart         # テスト用 MaterialApp ラッパー
│   │   └── mock_services.dart    # モックサービス定義
│   ├── unit/                     # ユニットテスト（28ファイル）
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   └── utils/
│   └── widget/                   # ウィジェット・画面テスト
│       ├── screens/
│       ├── widgets/
│       └── design_system/
├── docs/                         # ドキュメント
│   ├── onboarding.md             # このファイル（引き継ぎ）
│   ├── testing-strategy.md       # テスト詳細方針
│   ├── business-strategy.md      # 事業戦略 v1（全国展開モデル）
│   └── business-strategy-v2.md  # 事業戦略 v2（蒲郡実証モデル・最新）
└── CLAUDE.md                     # Claude Code へのルール指示（毎回読み込まれる）
```

---

## 5. アーキテクチャのルール

### レイヤー構造（必ず守ること）

```
screens → providers → services → models
```

**絶対に守るルール：screens から services を直接呼ばない。**
必ず providers を経由する。

```dart
// ❌ 間違い（screens から直接 service を呼ぶ）
class BoardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ThreadService().getThreads(stationId); // NG!
  }
}

// ✅ 正しい（providers を経由する）
class BoardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(threadsProvider(stationId)); // OK
  }
}
```

### 各レイヤーの責務

| レイヤー | 責務 | 責務外 |
|---------|------|--------|
| `models/` | データ構造の定義（fromJson, toJson, copyWith） | ビジネスロジック・通信 |
| `services/` | データの取得・保存（Supabase通信・モックデータ） | UI・状態管理 |
| `providers/` | 状態の管理（loading/data/error の切り替え） | UI描画・通信 |
| `widgets/` | 再利用可能なUIパーツ | Providerを直接 watch しない |
| `screens/` | 画面のUI + providers の watch | services の直接呼び出し |

### 命名規則

```
ファイル:   station_card.dart      （snake_case）
クラス:     StationCard            （PascalCase）
変数・関数: stationName            （camelCase）
Provider:  threadsProvider         （xxxProvider）
Service:   ThreadService           （XxxService）
Notifier:  ThreadsNotifier         （XxxNotifier）
画面:      BoardScreen             （XxxScreen）
ウィジェット: ThreadCard           （用途を表す名前）
```

---

## 6. データの流れを追う

### 例：「駅をタップしてスレッド一覧が表示されるまで」

```
1. ユーザーが HomeScreen で駅カードをタップ
   ↓
2. BoardScreen に Location オブジェクトを渡してナビゲート
   Navigator.push(BoardScreen(location: location))
   ↓
3. BoardScreen が表示される
   ref.watch(threadsProvider(location.id)) を呼ぶ
   ↓
4. ThreadsNotifier が build() を実行
   ThreadService().getThreads(stationId) を呼ぶ
   ↓
5. ThreadService がデータを返す
   モックモード: リスト内のダミーデータから該当するものを返す
   本番モード:   Supabase の threads テーブルから取得
   ↓
6. Notifier が AsyncData(threads) にセット
   ↓
7. BoardScreen の ref.watch が更新を検知
   ThreadCard のリストを描画する
```

### 例：「スレッドを作成するまで」

```
1. CreateThreadScreen でフォーム入力 → 投稿ボタンタップ
   ↓
2. ref.read(threadsProvider(stationId).notifier).createThread(...)
   ↓
3. ThreadsNotifier.createThread() が実行される
   ↓
4. ThreadService.createThread() を呼ぶ
   ├─ InputSanitizer.sanitize(title) でHTMLタグ・制御文字を除去
   ├─ NgWordFilter.check(title) でNGワードチェック（引っかかれば例外）
   └─ Supabase に insert
   ↓
5. 成功後、自動的に refresh() して最新のスレッド一覧を再取得
   ↓
6. BoardScreen に戻る（pop）
```

---

## 7. モックモードと本番モード

### なぜモックモードがあるのか

- Supabase への接続なしでもアプリを動かして開発できるようにするため
- テストで Supabase を使わなくてよくなる（速くて安定）

### 切り替えの仕組み

```dart
// lib/services/supabase_service.dart

class SupabaseService {
  // 環境変数が設定されていない場合は自動的にモックモード
  static bool get useMock =>
    const String.fromEnvironment('SUPABASE_URL').isEmpty;
}
```

### 各サービスでのモックデータ定義例

```dart
// lib/services/thread_service.dart

class ThreadService {
  // モック用データ（スタティック定義）
  static final List<Thread> _mockThreads = [
    Thread(
      id: 'thread-1',
      stationId: 'mock-1',      // mock-1 = 東京駅のモックID
      title: '今日の中央線どうですか',
      body: '8時頃かなり混んでいました',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      postCount: 5,
    ),
    // ...
  ];

  Future<List<Thread>> getThreads(String stationId) async {
    if (SupabaseService.useMock) {
      // モックデータから該当する駅のスレッドだけ返す
      return _mockThreads.where((t) => t.stationId == stationId).toList();
    }
    // 本番: Supabase から取得
    final res = await SupabaseService.client
      .from('threads')
      .select()
      .eq('station_id', stationId)
      .order('last_posted_at', ascending: false);
    return (res as List).map((e) => Thread.fromJson(e)).toList();
  }
}
```

### モックデータの駅ID一覧（NearbyLocationService）

| モックID | 駅名 | 補足 |
|---------|------|------|
| `mock-1` | 東京駅（東海道線） | |
| `mock-2` | 有楽町駅（山手線） | |
| `mock-3` | 神田駅（中央線） | |
| `event-1` | 森道市場2026 | LocationType.event |

---

## 8. よく使うコマンド集

```bash
# アプリ起動（モックモード）
flutter run

# アプリ起動（Supabase接続）
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...

# 全テスト実行（作業完了前に必ず実行）
flutter test

# 特定ディレクトリのテストのみ
flutter test test/unit/
flutter test test/widget/

# 特定ファイルのテストのみ（高速）
flutter test test/unit/models/thread_test.dart

# 静的解析（型エラー・未使用変数などを検出）
flutter analyze

# パッケージ更新
flutter pub get

# コード自動フォーマット
dart format lib/ test/

# カバレッジレポート生成
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 9. 機能を追加するときの手順

### 例：「お気に入りスレッド機能を追加する」

**ステップ1: モデルを確認・変更する（必要な場合）**

```dart
// lib/models/thread.dart に isFavorite フィールドを追加する場合
class Thread {
  final bool isFavorite;   // 追加

  const Thread({
    // ...
    this.isFavorite = false,
  });

  Thread copyWith({bool? isFavorite}) {
    return Thread(
      // ...
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
```

**ステップ2: サービスを追加・変更する**

```dart
// lib/services/favorite_service.dart を新規作成する場合
class FavoriteService {
  // モック用データ
  static final Set<String> _mockFavorites = {};

  Future<void> addFavorite(String threadId) async {
    if (SupabaseService.useMock) {
      _mockFavorites.add(threadId);
      return;
    }
    await SupabaseService.client.from('favorites').insert({'thread_id': threadId});
  }
}
```

**ステップ3: プロバイダを追加する**

```dart
// lib/providers/favorite_provider.dart
final favoriteServiceProvider = Provider((ref) => FavoriteService());

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    // 初期データを取得して返す
  }

  Future<void> toggleFavorite(String threadId) async {
    // お気に入りの追加・削除
  }
}
```

**ステップ4: 画面・ウィジェットに組み込む**

```dart
// screens / widgets で ref.watch を使う
final favorites = ref.watch(favoritesProvider);
```

**ステップ5: テストを書く（必須）**

変更したレイヤーごとに対応するテストファイルにテストを追加する。
（詳しくは次のセクション参照）

**ステップ6: テストを全件 pass させる**

```bash
flutter test
```

---

## 10. テストの書き方

テストの詳細な観点は `docs/testing-strategy.md` を参照してください。
ここでは「実際にどう書くか」を示します。

### Model のテスト例

```dart
// test/unit/models/thread_test.dart

group('Thread', () {
  // テストデータ
  final validJson = {
    'id': 'test-id',
    'station_id': 'station-1',
    'title': 'テストスレッド',
    'body': '本文です',
    'created_at': '2026-01-01T00:00:00.000Z',
    'post_count': 3,
    'last_posted_at': null,
  };

  test('正常なJSONからThreadが生成される', () {
    // Arrange
    // (validJson が Arrange に相当)

    // Act
    final thread = Thread.fromJson(validJson);

    // Assert
    expect(thread.id, 'test-id');
    expect(thread.title, 'テストスレッド');
    expect(thread.postCount, 3);
  });

  test('toJson → fromJson で同一性が保たれる', () {
    // Arrange
    final original = Thread.fromJson(validJson);

    // Act
    final restored = Thread.fromJson(original.toJson());

    // Assert
    expect(restored.id, original.id);
    expect(restored.title, original.title);
  });
});
```

### Service のテスト例（モックモード）

```dart
// test/unit/services/thread_service_test.dart

group('ThreadService（モックモード）', () {
  // モックモードは環境変数が未設定なので自動的に有効

  test('getThreads でモックデータが返る', () async {
    // Arrange
    final service = ThreadService();

    // Act
    final threads = await service.getThreads('mock-1');

    // Assert
    expect(threads, isNotEmpty);
    expect(threads.every((t) => t.stationId == 'mock-1'), isTrue);
  });

  test('createThread 後にリストに追加される', () async {
    // Arrange
    final service = ThreadService();
    const stationId = 'mock-1';

    // Act
    await service.createThread(
      stationId: stationId,
      title: 'テストスレッド',
      body: '本文',
    );
    final threads = await service.getThreads(stationId);

    // Assert
    expect(threads.any((t) => t.title == 'テストスレッド'), isTrue);
  });
});
```

### Widget テスト例

```dart
// test/widget/widgets/thread_card_test.dart

import 'package:flutter_test/flutter_test.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ThreadCard', () {
    test('スレッドのタイトルが表示される', () async {
      // Arrange
      final thread = TestFixtures.thread(title: '中央線どうですか');

      // Act
      await tester.pumpWidget(
        buildTestApp(
          ThreadCard(thread: thread, onTap: () {}),
        ),
      );

      // Assert
      expect(find.text('中央線どうですか'), findsOneWidget);
    });
  });
}
```

### テスト用ヘルパーの使い方

```dart
// test/helpers/fixtures.dart を使うと簡単にテストデータを作れる
final station = TestFixtures.station(name: '新宿駅');
final thread  = TestFixtures.thread(title: 'テスト');
final post    = TestFixtures.post(body: '返信です');

// test/helpers/test_app.dart
// Widget テストで MaterialApp + ProviderScope をまとめてセットアップ
buildTestApp(MyWidget(), overrides: [...])
```

---

## 11. デザインシステムの使い方

色・余白・角丸は `lib/design_system/tokens.dart` の定数を使います。
**ハードコードした値（`Color(0xFF...)` や `16.0` など）を直接書かないこと。**

### 色の使い方

```dart
import 'package:my_first_app/design_system/tokens.dart';

// ✅ 正しい（定数を使う）
Container(color: AppColors.primary)         // メインカラー #4299F0
Container(color: AppColors.bgCanvasLight)   // 背景色（ライトモード）
Text('テキスト', style: TextStyle(color: AppColors.textMainLight))

// ❌ 間違い（ハードコード → ダークモードで壊れる）
Container(color: Color(0xFF4299F0))
Container(color: Colors.white)
```

### ダークモード対応

Theme.of(context) を使って色を取得すれば自動でダークモードに対応します。

```dart
// ✅ Theme から色を取得する（推奨）
final color = Theme.of(context).colorScheme.surface;

// ✅ または tokens.dart の Brightness 判定
final isDark = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDark ? AppColors.bgCanvasDark : AppColors.bgCanvasLight;
```

### 余白・角丸

```dart
// 余白
Padding(padding: EdgeInsets.all(AppSpacing.sm))     // 16.0
Padding(padding: EdgeInsets.all(AppSpacing.md))     // 24.0

// 角丸
BorderRadius.circular(AppRadius.card)               // 16.0
BorderRadius.circular(AppRadius.lg)                 // 32.0
```

### 汎用コンポーネント（components.dart）

```dart
// ボタン
AppButton(
  label: '投稿する',
  onPressed: () => ...,
  variant: AppButtonVariant.primary,   // primary / secondary / ghost
  icon: Icons.send,                    // オプション
)

// カード
AppCard(
  padding: AppCardPadding.comfortable,   // compact / comfortable
  onTap: () => ...,                      // オプション
  child: ...,
)
```

---

## 12. 事業の現在地と今後の計画

### 現在のフェーズ：実証実験前

アプリ自体はほぼ完成しています。
今後は実際のユーザーに使ってもらい、「人は本当に書き込むのか」を検証します。

### 直近の実証計画（business-strategy-v2.md より）

| 時期 | やること |
|------|---------|
| 2026年3月 | アプリ名決定・X(Twitter)アカウント作成・Web版開発着手 |
| 2026年4月 | Web版完成・シード投稿作成・フライヤー印刷 |
| **2026年5月** | **★ 森、道、市場（蒲郡の音楽フェス）で実証実験★** |
| 2026年6月 | 結果分析・改善 |
| **2026年7月** | **★ 蒲郡花火大会で2回目の実証 ★** |
| 2026年8月〜 | 結果をもとに次の方向性を判断 |

### 成功基準（KPI）

森道での3日間で以下を達成できれば「Go（継続）」判定：

| 指標 | 目標値 |
|------|--------|
| Web訪問数 | 300以上 |
| 投稿数 | 100以上 |
| 同時接続数 | 30以上 |
| 翌日再訪率 | 20%以上 |
| 自然発生スレッド | 1以上（運営が作っていないもの） |

### Web版について

現在のアプリは iOS/Android ネイティブのみ。
森道ではインストール不要の **Web版** が必要なため別途開発します。

```
技術選定:   Next.js + Supabase JS Client（別リポジトリで管理）
用途:       QRコードから直接アクセスできるブラウザ版
位置情報:   不要（QRから直接イベントページに飛ぶ）
リポジトリ: my_first_app_admin（別リポジトリ予定）
```

---

## 13. やってはいけないこと

### コード面

```dart
// ❌ screens から services を直接呼ぶ
ThreadService().getThreads(id);   // screens から NG

// ❌ ハードコードした色
Color(0xFF4299F0)                 // AppColors.primary を使う
Colors.white                      // AppColors.bgCanvasLight を使う

// ❌ async gap 後に BuildContext を使う（クラッシュする）
await someAsyncOperation();
if (!mounted) return;             // これを忘れると NG
Navigator.pop(context);           // mounted チェック後に使う

// ❌ models にビジネスロジックを入れる
class Thread {
  List<Post> fetchPosts() { ... } // models にはロジックを入れない
}

// ❌ print をコミットに残す
print('デバッグ用');              // debugPrint を使い、コミット前に削除

// ❌ 指示されていない機能を追加する
// 「ついでに」リファクタリング、
// 機能追加は全てユーザーへの確認後
```

### Git 面

```bash
# ❌ 確認なしで push
git push origin main

# ❌ 確認なしでコミット
git commit -m "..."

# ❌ main ブランチに直接コミット
# → 作業ブランチを切ってから PR を出す

# ❌ force push
git push --force
```

### 設計面

- ユーザー登録・ログイン機能を追加しない（匿名性が核心）
- DM・チャット機能を追加しない（掲示板形式を守る）
- 地図表示を追加しない（現時点ではスコープ外）
- 広告・課金機能はフェーズが来るまで追加しない

---

## 14. 困ったときの調べ方

### このプロジェクト内のドキュメント

| ドキュメント | 内容 |
|-------------|------|
| `CLAUDE.md` | 開発ルール総まとめ（最優先） |
| `docs/testing-strategy.md` | テストの詳細な観点・コマンド |
| `docs/business-strategy-v2.md` | 最新の事業戦略（蒲郡実証モデル） |
| `docs/design-system/` | デザインシステムの詳細仕様 |

### よくある疑問

**Q. モックモードと本番モードのどちらで開発すればいい？**
A. 基本はモックモードで開発して、Supabase 接続が必要なときだけ切り替える。

**Q. 新しいファイルはどこに作ればいい？**
A. レイヤーに合った場所に作る（models/, services/, providers/ など）。
   既存ファイルへの追記で済む場合は新規ファイルを作らない。

**Q. テストはいつ書けばいい？**
A. コードを変更した直後。「後で書く」は書かないのと同じ。

**Q. Supabase のテーブル構造はどこで確認できる？**
A. Supabase ダッシュボードの Table Editor で確認する。
   変更する場合は必ずユーザーに確認すること（マイグレーション管理が必要）。

**Q. エラーが出てどうしても解決できない場合は？**
A. `flutter analyze` でまず静的解析を確認する。
   Dart のエラーメッセージは日本語に翻訳しつつ読むと理解しやすい。

---

## まとめ：最初の1週間でやること

```
Day 1: このドキュメントを全部読む
        flutter run でアプリを起動して画面遷移を全部触ってみる

Day 2: flutter test を実行して全件 pass を確認する
        テストファイルを1〜2個読んで書き方を把握する

Day 3: 簡単なバグ修正や表示の調整をやってみる
        変更 → テスト → flutter test の流れを体験する

Day 4-5: ドキュメント（docs/）を全部読む
          事業の背景・方向性を理解する

Day 6-7: 担当タスクを確認して開発開始
          わからないことはまず CLAUDE.md と testing-strategy.md を確認する
```

---

*最終更新: 2026-02-23*
