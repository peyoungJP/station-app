import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/providers/thread_provider.dart';
import 'package:my_first_app/screens/thread_detail_screen.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_services.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ThreadDetailScreen', () {
    late MockPostService mockPostService;

    setUp(() {
      mockPostService = MockPostService();
    });

    testWidgets('スレッドタイトルが表示される', (tester) async {
      final thread = TestFixtures.thread(title: 'テスト用タイトル');

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // AppBarとbody内の両方に表示される
      expect(find.text('テスト用タイトル'), findsAtLeast(1));
    });

    testWidgets('スレッド本文が表示される', (tester) async {
      final thread = TestFixtures.thread(body: 'これはテスト本文です');

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('これはテスト本文です'), findsOneWidget);
    });

    testWidgets('返信入力フィールドが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('返信を入力...'), findsOneWidget);
    });

    testWidgets('通報アイコンが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('送信ボタンが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('返信送信に失敗した場合、エラーSnackBarが表示され送信ボタンが再び有効になる',
        (tester) async {
      mockPostService.shouldThrowOnCreate = true;
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'テスト返信');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('返信の送信に失敗しました。もう一度お試しください。'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('NGワードが含まれる返信の場合、専用エラーSnackBarが表示される', (tester) async {
      mockPostService.shouldThrowNgWord = true;
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(
          ThreadDetailScreen(thread: thread),
          overrides: [
            postServiceProvider.overrideWithValue(mockPostService),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'テスト返信');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      expect(find.text('不適切な表現が含まれているため投稿できません。'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
