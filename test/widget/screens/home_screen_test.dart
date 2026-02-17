import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/screens/home_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('駅掲示板のタイトルが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump();

      expect(find.text('駅掲示板'), findsOneWidget);
    });

    testWidgets('設定アイコンが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const HomeScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
