import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/screens/thread_detail_screen.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ThreadDetailScreen', () {
    testWidgets('スレッドタイトルが表示される', (tester) async {
      final thread = TestFixtures.thread(title: 'テスト用タイトル');

      await tester.pumpWidget(
        buildTestApp(ThreadDetailScreen(thread: thread)),
      );
      await tester.pumpAndSettle();

      // AppBarとbody内の両方に表示される
      expect(find.text('テスト用タイトル'), findsAtLeast(1));
    });

    testWidgets('スレッド本文が表示される', (tester) async {
      final thread = TestFixtures.thread(body: 'これはテスト本文です');

      await tester.pumpWidget(
        buildTestApp(ThreadDetailScreen(thread: thread)),
      );
      await tester.pumpAndSettle();

      expect(find.text('これはテスト本文です'), findsOneWidget);
    });

    testWidgets('返信入力フィールドが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(ThreadDetailScreen(thread: thread)),
      );
      await tester.pumpAndSettle();

      expect(find.text('返信を入力...'), findsOneWidget);
    });

    testWidgets('通報アイコンが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(ThreadDetailScreen(thread: thread)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });

    testWidgets('送信ボタンが表示される', (tester) async {
      final thread = TestFixtures.thread();

      await tester.pumpWidget(
        buildTestApp(ThreadDetailScreen(thread: thread)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.send), findsOneWidget);
    });
  });
}
