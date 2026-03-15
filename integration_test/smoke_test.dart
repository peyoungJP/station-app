// E2E スモークテスト
//
// geolocator は Flutter Web 非対応のため、CI 環境（Linux + Chrome）では
// 位置情報は拒否される。ここでは「アプリが起動して画面が表示される」ことのみ確認する。
//
// 実行コマンド:
//   flutter test integration_test/smoke_test.dart -d chrome
//
// ローカルでは事前に Chrome が必要。
// CI では browser-actions/setup-chrome アクションでセットアップ済み。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// モックモードで動作させるため環境変数なしで main() を呼び出す
// SupabaseService.hasConfig == false → _useMock = true のまま初期化される
import 'package:my_first_app/main.dart' as app;

void main() {
  // integration_test パッケージが必須とする初期化
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('スモークテスト', () {
    testWidgets('アプリが起動してホーム画面が表示される', (tester) async {
      // アプリを起動する
      app.main();

      // 非同期処理（Supabase 初期化・Provider 読み込み）が落ち着くまで待つ
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // MaterialApp が存在することを確認
      expect(find.byType(MaterialApp), findsOneWidget,
          reason: 'MaterialApp が描画されていない');

      // Scaffold（画面の骨格）が表示されること
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1),
          reason: 'Scaffold が描画されていない');

      // アプリタイトル「駅掲示板」が AppBar に表示されること
      // HomeScreen では AppBar title に '駅掲示板' を使っている
      expect(find.text('駅掲示板'), findsWidgets,
          reason: '駅掲示板 のテキストが見つからない');
    });
  });
}
