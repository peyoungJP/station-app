import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/providers/thread_provider.dart';
import 'package:my_first_app/screens/board_screen.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_app.dart';

void main() {
  group('BoardScreen', () {
    late MockThreadService mockThreadService;

    setUp(() {
      mockThreadService = MockThreadService();
    });

    testWidgets('AppBarにstation型の場合「〜駅」が表示される', (tester) async {
      final location = TestFixtures.location(name: '東京');

      await tester.pumpWidget(
        buildTestApp(
          BoardScreen(location: location),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('東京駅'), findsOneWidget);
    });

    testWidgets('FABが表示される', (tester) async {
      final location = TestFixtures.location();

      await tester.pumpWidget(
        buildTestApp(
          BoardScreen(location: location),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('スレッド作成'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('スレッド一覧がある場合にスレッドが表示される', (tester) async {
      final location = TestFixtures.location();
      mockThreadService.mockResult = [
        TestFixtures.thread(title: 'テストスレッド1', stationId: location.id),
      ];

      await tester.pumpWidget(
        buildTestApp(
          BoardScreen(location: location),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('テストスレッド1'), findsOneWidget);
    });

    testWidgets('スレッドがない場合に空状態メッセージが表示される', (tester) async {
      final location = TestFixtures.location();
      mockThreadService.mockResult = [];

      await tester.pumpWidget(
        buildTestApp(
          BoardScreen(location: location),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('まだスレッドがありません'), findsOneWidget);
    });

    testWidgets('エラーの場合、エラーメッセージと再試行ボタンが表示される', (tester) async {
      final location = TestFixtures.location();
      mockThreadService.shouldThrow = true;

      await tester.pumpWidget(
        buildTestApp(
          BoardScreen(location: location),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('エラーが発生しました'), findsOneWidget);
      expect(find.text('再試行'), findsOneWidget);
    });
  });
}
