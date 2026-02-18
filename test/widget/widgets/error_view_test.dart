import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/error_view.dart';

import '../../helpers/test_app.dart';

void main() {
  group('ErrorView', () {
    testWidgets('通信エラーの場合、通信エラーメッセージが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Center(
            child: ErrorView(
              error: Exception('SocketException: connection refused'),
            ),
          ),
        ),
      );

      expect(find.text('エラーが発生しました'), findsOneWidget);
      expect(
        find.text('通信エラーが発生しました。通信環境を確認してください。'),
        findsOneWidget,
      );
    });

    testWidgets('その他のエラーの場合、サーバーエラーメッセージが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Center(
            child: ErrorView(error: Exception('テストエラー')),
          ),
        ),
      );

      expect(find.text('エラーが発生しました'), findsOneWidget);
      expect(
        find.text('サーバーエラーが発生しました。しばらくしてからお試しください。'),
        findsOneWidget,
      );
    });

    testWidgets('onRetryがある場合、再試行ボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Center(
            child: ErrorView(
              error: Exception('テストエラー'),
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('再試行'), findsOneWidget);
    });

    testWidgets('onRetryがない場合、再試行ボタンが表示されない', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Center(
            child: ErrorView(error: Exception('テストエラー')),
          ),
        ),
      );

      expect(find.text('再試行'), findsNothing);
    });

    testWidgets('再試行ボタンをタップするとonRetryが呼ばれる', (tester) async {
      var called = false;

      await tester.pumpWidget(
        buildTestApp(
          Center(
            child: ErrorView(
              error: Exception('テストエラー'),
              onRetry: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('再試行'));
      expect(called, isTrue);
    });
  });
}
