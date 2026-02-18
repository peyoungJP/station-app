import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/screens/legal_screen.dart';
import 'package:my_first_app/screens/settings_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('設定画面のタイトルが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('設定'), findsOneWidget);
    });

    testWidgets('情報セクションが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('情報'), findsOneWidget);
    });

    testWidgets('アプリセクションが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('アプリ'), findsOneWidget);
    });

    testWidgets('利用規約メニューが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('利用規約'), findsOneWidget);
    });

    testWidgets('プライバシーポリシーメニューが表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('プライバシーポリシー'), findsOneWidget);
    });

    testWidgets('バージョン情報が表示される', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('バージョン'), findsOneWidget);
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('利用規約をタップすると利用規約画面に遷移する', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('利用規約'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('利用規約'), findsWidgets);
    });

    testWidgets('プライバシーポリシーをタップするとプライバシーポリシー画面に遷移する', (tester) async {
      await tester.pumpWidget(buildTestApp(const SettingsScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('プライバシーポリシー'));
      await tester.pumpAndSettle();

      expect(find.byType(LegalScreen), findsOneWidget);
      expect(find.text('プライバシーポリシー'), findsWidgets);
    });
  });
}

