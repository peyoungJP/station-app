import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/thread_card.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('ThreadCard', () {
    testWidgets('タイトルが表示される', (tester) async {
      // Arrange
      final thread = TestFixtures.thread(title: '電車遅延情報');
      final widget = buildTestApp(
        Scaffold(
          body: ThreadCard(thread: thread, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('電車遅延情報'), findsOneWidget);
    });

    testWidgets('本文が表示される', (tester) async {
      // Arrange
      final thread = TestFixtures.thread(body: '今日は10分遅れています');
      final widget = buildTestApp(
        Scaffold(
          body: ThreadCard(thread: thread, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('今日は10分遅れています'), findsOneWidget);
    });

    testWidgets('返信数が表示される', (tester) async {
      // Arrange
      final thread = TestFixtures.thread(postCount: 5);
      final widget = buildTestApp(
        Scaffold(
          body: ThreadCard(thread: thread, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('タップ時にonTapコールバックが呼ばれる', (tester) async {
      // Arrange
      var tapped = false;
      final thread = TestFixtures.thread();
      final widget = buildTestApp(
        Scaffold(
          body: ThreadCard(
            thread: thread,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(ThreadCard));

      // Assert
      expect(tapped, isTrue);
    });
  });
}
