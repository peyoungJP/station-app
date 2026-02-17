import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/post_item.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('PostItem', () {
    testWidgets('番号バッジが表示される（index+1）', (tester) async {
      // Arrange
      final post = TestFixtures.post();
      final widget = buildTestApp(
        Scaffold(
          body: PostItem(post: post, index: 4, onReport: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('本文が表示される', (tester) async {
      // Arrange
      final post = TestFixtures.post(body: 'こんにちは、テスト投稿です');
      final widget = buildTestApp(
        Scaffold(
          body: PostItem(post: post, index: 0, onReport: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('こんにちは、テスト投稿です'), findsOneWidget);
    });

    testWidgets('通報メニューが表示される', (tester) async {
      // Arrange
      final post = TestFixtures.post();
      final widget = buildTestApp(
        Scaffold(
          body: PostItem(post: post, index: 0, onReport: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });
}
