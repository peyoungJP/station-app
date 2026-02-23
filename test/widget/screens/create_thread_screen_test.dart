import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/providers/thread_provider.dart';
import 'package:my_first_app/screens/create_thread_screen.dart';

import '../../helpers/mock_services.dart';
import '../../helpers/test_app.dart';

void main() {
  group('CreateThreadScreen', () {
    late MockThreadService mockThreadService;

    setUp(() {
      mockThreadService = MockThreadService();
    });

    testWidgets('スレッド作成のタイトルが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('スレッド作成'), findsOneWidget);
    });

    testWidgets('タイトル入力フィールドが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('タイトル'), findsOneWidget);
    });

    testWidgets('本文入力フィールドが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('本文'), findsOneWidget);
    });

    testWidgets('投稿ボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('投稿'), findsOneWidget);
    });

    testWidgets('匿名投稿の注意テキストが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('投稿は匿名で行われます。個人情報の記載はお控えください。'),
        findsOneWidget,
      );
    });

    testWidgets('投稿に失敗した場合、エラーSnackBarが表示され投稿ボタンが再び有効になる',
        (tester) async {
      mockThreadService.shouldThrowOnCreate = true;

      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'テストタイトル');
      await tester.enterText(find.byType(TextFormField).last, 'テスト本文です');
      await tester.tap(find.text('投稿'));
      await tester.pumpAndSettle();

      expect(find.text('投稿に失敗しました。もう一度お試しください。'), findsOneWidget);
      expect(find.text('投稿'), findsOneWidget);
    });

    testWidgets('NGワードが含まれる場合、専用エラーSnackBarが表示される', (tester) async {
      mockThreadService.shouldThrowNgWord = true;

      await tester.pumpWidget(
        buildTestApp(
          const CreateThreadScreen(stationId: 'test-station-1'),
          overrides: [
            threadServiceProvider.overrideWithValue(mockThreadService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'テストタイトル');
      await tester.enterText(find.byType(TextFormField).last, 'テスト本文です');
      await tester.tap(find.text('投稿'));
      await tester.pumpAndSettle();

      expect(find.text('不適切な表現が含まれているため投稿できません。'), findsOneWidget);
      expect(find.text('投稿'), findsOneWidget);
    });
  });
}
