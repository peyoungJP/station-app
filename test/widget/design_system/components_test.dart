import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/design_system/components.dart';

import '../../helpers/test_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('Primary variantのボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: 'テストボタン',
              variant: AppButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('テストボタン'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('Secondary variantのボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: 'セカンダリ',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('セカンダリ'), findsOneWidget);
    });

    testWidgets('Ghost variantのボタンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: 'ゴースト',
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ゴースト'), findsOneWidget);
    });

    testWidgets('onPressedがnullの場合に非活性表示になる', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: '非活性',
              onPressed: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('タップ時にonPressedコールバックが呼ばれる', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: 'タップ',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('タップ'));
      expect(tapped, isTrue);
    });

    testWidgets('icon指定時にアイコンが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppButton(
              label: 'アイコン付き',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppCard', () {
    testWidgets('子ウィジェットが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppCard(
              child: Text('カード内容'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('カード内容'), findsOneWidget);
    });

    testWidgets('タップ時にonTapコールバックが呼ばれる', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        buildTestApp(
          Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: Text('タップカード'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('タップカード'));
      expect(tapped, isTrue);
    });
  });
}
