# エキレコ テスト戦略 v1.0

このドキュメントは、本プロジェクトのテスト方針・ルール・観点を定義する。
すべてのテスト実装はこのドキュメントに従うこと。

---

## 1. テストピラミッド（バランス方針）

```
        ╱  ╲
       ╱ E2E ╲          ~10%（5本程度）
      ╱────────╲
     ╱  Widget  ╲       ~30%（15–20本）
    ╱────────────╲
   ╱    Unit      ╲     ~60%（30–40本）
  ╱────────────────╲
```

| レイヤー | 比率 | 対象 | 実行速度 |
|---------|------|------|---------|
| Unit | ~60% | Models, Services, Providers, ロジック関数 | 最速（ms単位） |
| Widget | ~30% | Widgets, Screens（UIコンポーネント単位） | 中速（秒単位） |
| Integration (E2E) | ~10% | 主要ユーザーフロー（画面遷移を含む） | 低速（数秒〜） |

> **原則：下層ほど多く、上層ほど少なく。** ロジックのバグは Unit で、UIの表示崩れは Widget で、フロー全体の整合性は E2E で検証する。

---

## 2. ディレクトリ構成

```
test/
├── unit/
│   ├── models/
│   │   ├── station_test.dart
│   │   ├── thread_test.dart
│   │   ├── post_test.dart
│   │   └── report_test.dart
│   ├── services/
│   │   ├── station_service_test.dart
│   │   ├── thread_service_test.dart
│   │   ├── post_service_test.dart
│   │   ├── report_service_test.dart
│   │   └── location_service_test.dart
│   └── providers/
│       ├── location_provider_test.dart
│       ├── station_provider_test.dart
│       └── thread_provider_test.dart
├── widget/
│   ├── widgets/
│   │   ├── station_card_test.dart
│   │   ├── thread_card_test.dart
│   │   └── post_item_test.dart
│   ├── screens/
│   │   ├── home_screen_test.dart
│   │   ├── board_screen_test.dart
│   │   ├── create_thread_screen_test.dart
│   │   ├── thread_detail_screen_test.dart
│   │   └── settings_screen_test.dart
│   └── design_system/
│       ├── components_test.dart
│       └── theme_test.dart
├── helpers/
│   ├── test_app.dart          # MaterialApp + ProviderScope ラッパー
│   ├── mock_services.dart     # Service のモック定義
│   └── fixtures.dart          # テスト用データファクトリ
└── integration/
    └── (integration_test/ ディレクトリに配置)

integration_test/
├── app_flow_test.dart         # 主要フロー E2E
└── helpers/
    └── test_setup.dart
```

---

## 3. レイヤー別テスト方針

### 3.1 Unit テスト

#### Models（必須・全モデル）
| 観点 | 内容 |
|------|------|
| fromJson | 正常なJSONからインスタンスが正しく生成される |
| fromJson 異常系 | 必須フィールド欠損時にエラーになる |
| toJson | インスタンスから正しいJSON Mapが生成される |
| toJson → fromJson 往復 | シリアライズ→デシリアライズで同一性が保たれる |
| copyWith | 指定フィールドのみ変更され他は維持される |
| const コンストラクタ | イミュータブルであること |
| デフォルト値 | オプショナルフィールドの初期値が正しい（例：`postCount = 0`） |

```dart
// 例：Station モデル
group('Station', () {
  test('fromJson で正しくパースされる', () {
    final json = {'id': '1', 'name': '東京', ...};
    final station = Station.fromJson(json);
    expect(station.name, '東京');
  });

  test('toJson → fromJson で等価', () {
    const station = Station(id: '1', name: '東京', ...);
    final restored = Station.fromJson(station.toJson());
    expect(restored.id, station.id);
  });
});
```

#### Services（必須・全サービス）
| 観点 | 内容 |
|------|------|
| モックモード正常系 | `useMock = true` 時にモックデータが返る |
| モックモード件数 | 期待するデータ件数が返る |
| 作成操作 | createXxx 後にリストに追加されている |
| 空データ | 該当データがないstationId等で空リストが返る |

> **注意**: Supabase実通信のテストは Integration に含める。Unit ではモックモードのみテストする。

#### Services — LocationService（特殊）
| 観点 | 内容 |
|------|------|
| calculateDistance | 既知の2点間距離が正しい（東京駅↔有楽町駅など） |
| calculateDistance 同一点 | 同じ座標で距離 0 |
| _toRadians | 0°→0, 180°→π, 360°→2π |

> `Geolocator` 依存のメソッド（`getCurrentPosition` 等）は Widget/Integration でモックする。

#### Providers（必須・全プロバイダ）
| 観点 | 内容 |
|------|------|
| 初期状態 | build() 直後の state が期待値（null / 空リスト） |
| fetchXxx 成功 | Service が成功を返した場合に state が AsyncData になる |
| fetchXxx 失敗 | Service が例外を投げた場合に state が AsyncError になる |
| refresh | 再取得後にデータが更新される |
| createXxx | 作成後に自動 refresh され新データが含まれる |

```dart
// 例：ThreadsNotifier
test('fetchThreads 成功時に AsyncData になる', () async {
  final container = ProviderContainer(overrides: [
    threadServiceProvider.overrideWithValue(mockThreadService),
  ]);
  // ...
  expect(container.read(threadsProvider('mock-1')), isA<AsyncData>());
});
```

---

### 3.2 Widget テスト

#### 共通観点（全 Widget / Screen）
| 観点 | 内容 |
|------|------|
| レンダリング | クラッシュせず描画される |
| テキスト表示 | 渡したデータが画面に表示される |
| タップ動作 | onTap / onPressed コールバックが発火する |
| ローディング | AsyncLoading 時に CircularProgressIndicator が表示される |
| エラー | AsyncError 時にエラーメッセージが表示される |
| 空状態 | データが空の場合に空メッセージが表示される |

#### Widget 個別

**StationCard**
| 観点 | 内容 |
|------|------|
| 駅名表示 | `station.name` が描画される |
| 路線名表示 | `station.lineName` が描画される |
| 距離バッジ | `station.distance` がある場合にバッジが表示される |
| 距離バッジ非表示 | `distance == null` の場合にバッジが非表示 |
| タップ | onTap コールバックが呼ばれる |

**ThreadCard**
| 観点 | 内容 |
|------|------|
| タイトル表示 | `thread.title` が描画される |
| 本文プレビュー | `thread.body` が最大2行で表示される |
| 返信数 | `thread.postCount` が表示される |
| 相対日時 | 「○分前」「○時間前」「○日前」形式で表示される |
| タップ | onTap コールバックが呼ばれる |

**PostItem**
| 観点 | 内容 |
|------|------|
| 番号バッジ | index+1 の番号が表示される |
| 本文表示 | `post.body` が描画される |
| 通報メニュー | PopupMenuButton をタップで通報オプションが表示される |
| 通報コールバック | 通報選択時に onReport が呼ばれる |

#### Screen 個別

**HomeScreen**
| 観点 | 内容 |
|------|------|
| 初期ローディング | 起動時に位置情報取得中のインジケータが表示される |
| 駅一覧表示 | 駅データ取得後に StationCard が表示される |
| 空状態 | 500m以内に駅がない場合のメッセージが表示される |
| 位置情報未許可 | 権限拒否時のメッセージとボタンが表示される |
| 設定遷移 | 設定アイコンタップで SettingsScreen に遷移する |
| 駅タップ遷移 | 駅カードタップで BoardScreen に遷移する |

**BoardScreen**
| 観点 | 内容 |
|------|------|
| AppBar タイトル | 「○○駅」形式で駅名が表示される |
| スレッド一覧 | ThreadCard が正しい件数表示される |
| 空状態 | スレッドがない場合のメッセージが表示される |
| FAB表示 | 「スレッド作成」ボタンが表示される |
| FABタップ遷移 | FABタップで CreateThreadScreen に遷移する |

**CreateThreadScreen**
| 観点 | 内容 |
|------|------|
| フォーム表示 | タイトル・本文フィールドが表示される |
| バリデーション（空） | 空送信時にエラーメッセージが表示される |
| 文字数制限 | タイトル50字・本文1000字を超えて入力できない |
| 投稿ボタン | 有効なフォームで投稿ボタンが活性化する |
| 送信中状態 | 送信中にローディングインジケータが表示される |
| 匿名注意書き | 匿名投稿の注意テキストが表示される |

**ThreadDetailScreen**
| 観点 | 内容 |
|------|------|
| スレッド本文表示 | タイトル・本文・日時が表示される |
| 返信一覧 | PostItem が正しい件数表示される |
| 空返信 | 返信がない場合のメッセージが表示される |
| 返信入力 | テキストフィールドに入力できる |
| 通報ダイアログ | 通報アイコンタップで理由選択ダイアログが開く |
| 通報理由 | 5つの通報理由が表示される |

**SettingsScreen**
| 観点 | 内容 |
|------|------|
| セクション表示 | 「情報」「アプリ」セクションが表示される |
| メニュー項目 | 利用規約・プライバシーポリシー・バージョンが表示される |
| バージョン | 「1.0.0」が表示される |

#### Design System

**AppButton**
| 観点 | 内容 |
|------|------|
| Primary variant | primary カラーで描画される |
| Secondary variant | secondary カラーで描画される |
| Ghost variant | primary10 背景で描画される |
| disabled | onPressed: null 時に非活性表示 |
| アイコン付き | icon 指定時にアイコンが表示される |

**AppCard**
| 観点 | 内容 |
|------|------|
| Compact padding | padding が AppSpacing.sm |
| Comfortable padding | padding が AppSpacing.md |
| タップ | onTap コールバックが呼ばれる |
| ダークモード | Dark テーマで surfaceDark カラーが使われる |

**AppTheme**
| 観点 | 内容 |
|------|------|
| Light テーマ | brightness が Brightness.light |
| Dark テーマ | brightness が Brightness.dark |
| カラーシード | colorSchemeSeed が AppColors.primary |
| CardTheme radius | card radius が AppRadius.card |

---

### 3.3 Integration テスト（E2E）

主要ユーザーフローを端から端まで検証する。モックモードで実行する。

| フロー | ステップ |
|--------|---------|
| 駅一覧→掲示板 | アプリ起動 → 駅一覧表示 → 駅タップ → 掲示板表示 |
| スレッド作成 | 掲示板 → FABタップ → タイトル・本文入力 → 投稿 → 掲示板に反映 |
| スレッド閲覧→返信 | 掲示板 → スレッドタップ → 詳細表示 → 返信入力 → 送信 → 反映 |
| 通報フロー | スレッド詳細 → 通報アイコン → 理由選択 → SnackBar 表示 |
| 設定表示 | ホーム → 設定アイコン → 設定画面表示 → 各メニュー確認 |

---

## 4. テストヘルパー方針

### 4.1 テスト用 MaterialApp ラッパー

```dart
// test/helpers/test_app.dart
Widget buildTestApp(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      theme: AppTheme.light,
      home: child,
    ),
  );
}
```

### 4.2 テスト用データファクトリ

```dart
// test/helpers/fixtures.dart
class TestFixtures {
  static Station station({
    String id = 'test-station-1',
    String name = 'テスト駅',
    String lineName = 'テスト線',
    double? distance = 100,
  }) => Station(
    id: id, name: name,
    latitude: 35.6812, longitude: 139.7671,
    prefecture: '東京都', lineName: lineName,
    distance: distance,
  );

  static Thread thread({...}) => Thread(...);
  static Post post({...}) => Post(...);
}
```

### 4.3 Service モック方針

| 方法 | 用途 |
|------|------|
| Provider Override | Riverpod の `overrideWithValue` でテスト用 Service を注入 |
| 手動モック | Service クラスを extends してメソッドをオーバーライド |

> **`mockito` / `mocktail` は必要になった段階で導入を検討する。** 現時点では手動モック + Provider Override で十分カバーできる。

---

## 5. テスト実行ルール

### 5.1 実行コマンド

```bash
# Unit + Widget テスト（全件）
flutter test

# 特定ディレクトリ
flutter test test/unit/
flutter test test/widget/

# 特定ファイル
flutter test test/unit/models/station_test.dart

# Integration テスト
flutter test integration_test/

# カバレッジ付き
flutter test --coverage
```

### 5.2 CI/CD 方針

| タイミング | 実行範囲 |
|-----------|---------|
| コミット前 | `flutter test`（Unit + Widget） |
| PR作成時 | `flutter test --coverage` + カバレッジレポート |
| マージ前 | Integration テスト |

### 5.3 カバレッジ目標

| レイヤー | 目標 | 備考 |
|---------|------|------|
| Models | 100% | 全 fromJson / toJson / copyWith |
| Services（モックロジック） | 80%+ | Supabase実通信部分は除外 |
| Providers | 80%+ | 全状態遷移パス |
| Widgets | 70%+ | 表示・タップの主要パス |
| Screens | 60%+ | 正常系 + 主要エラー系 |
| Design System | 70%+ | 全 variant / テーマ |
| **全体** | **70%+** | |

---

## 6. テスト品質ルール（MUST）

### 6.1 命名規則
- テストファイル名：`{対象ファイル名}_test.dart`
- group名：対象クラス名またはメソッド名
- test名：**日本語で「○○の場合、○○になる」** 形式

```dart
group('Station.fromJson', () {
  test('正常なJSONからStationが生成される', () { ... });
  test('distanceがnullの場合、nullのまま保持される', () { ... });
});
```

### 6.2 AAA パターン
すべてのテストは **Arrange → Act → Assert** の構成にする。

```dart
test('スレッド作成後にリストに追加される', () async {
  // Arrange
  final service = ThreadService();

  // Act
  await service.createThread(stationId: 'mock-1', title: 'テスト', body: '本文');
  final threads = await service.getThreads('mock-1');

  // Assert
  expect(threads.any((t) => t.title == 'テスト'), isTrue);
});
```

### 6.3 禁止事項
- テスト内で `sleep()` / 固定 `Duration` の `Future.delayed` を使わない（`pump` / `pumpAndSettle` を使う）
- テスト間で状態を共有しない（各テストは独立）
- 実装の詳細（privateメソッド）を直接テストしない
- テストで `print()` を残さない
- flaky（不安定）なテストを放置しない

### 6.4 推奨事項
- 1テスト1アサーション を基本とする（複数アサーションは関連がある場合のみ）
- Widget テストでは `find.text()` `find.byType()` `find.byIcon()` を活用する
- Provider テストでは `ProviderContainer` を使い、Widget に依存しない形で書く
- エッジケース（空文字、null、最大長、境界値）を意識する

---

## 7. テスト優先順位（実装順序）

Phase 1〜3 の順番で段階的に実装する。

### Phase 1: 基盤（最優先）
1. `test/helpers/` — テストヘルパー・fixtures
2. `test/unit/models/` — 全モデルの fromJson / toJson
3. `test/unit/services/location_service_test.dart` — calculateDistance

### Phase 2: ロジック層
4. `test/unit/services/` — 残りの全 Service（モックモード）
5. `test/unit/providers/` — 全 Provider の状態遷移

### Phase 3: UI層
6. `test/widget/widgets/` — 全 Widget の表示・タップ
7. `test/widget/screens/` — 全 Screen の主要パス
8. `test/widget/design_system/` — AppButton / AppCard / Theme

### Phase 4: フロー検証
9. `integration_test/` — 主要5フロー

---

## 8. テスト観点チェックリスト（PR レビュー用）

新機能・変更時に以下を確認する。

- [ ] 新しい Model に fromJson / toJson テストがある
- [ ] 新しい Service にモックモードのテストがある
- [ ] 新しい Provider に状態遷移テストがある
- [ ] 新しい Widget に表示テストがある
- [ ] 新しい Screen に正常系・空状態・エラー状態テストがある
- [ ] 既存テストが壊れていない（`flutter test` が全件 pass）
- [ ] テスト名が日本語で意図が明確
- [ ] テスト間の依存がない（単独実行可能）

---

## 9. 変更履歴

| 日付 | 変更内容 | 変更者 |
|------|----------|--------|
| 2026-02-16 | 初版作成 | Claude |
