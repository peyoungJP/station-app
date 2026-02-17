import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/screens/create_thread_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  group('CreateThreadScreen', () {
    testWidgets('スレッド作成のタイトルが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const CreateThreadScreen(stationId: 'test-station-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('スレッド作成'), findsOneWidget);
    });

    testWidgets('タイトル入力フィールドが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const CreateThreadScreen(stationId: 'test-station-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('タイトル'), findsOneWidget);
    });

    testWidgets('本文入力フィールドが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const CreateThreadScreen(stationId: 'test-station-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('本文'), findsOneWidget);
    });

    testWidgets('投稿ボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const CreateThreadScreen(stationId: 'test-station-1')),
      );
      await tester.pumpAndSettle();

      expect(find.text('投稿'), findsOneWidget);
    });

    testWidgets('匿名投稿の注意テキストが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(const CreateThreadScreen(stationId: 'test-station-1')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('投稿は匿名で行われます。個人情報の記載はお控えください。'),
        findsOneWidget,
      );
    });
  });
}
