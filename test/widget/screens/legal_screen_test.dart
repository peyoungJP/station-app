import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/screens/legal_screen.dart';

import '../../helpers/test_app.dart';

void main() {
  group('LegalScreen', () {
    group('利用規約画面', () {
      testWidgets('タイトルが表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.termsOfService()));
        await tester.pumpAndSettle();

        expect(find.text('利用規約'), findsOneWidget);
      });

      testWidgets('最終更新日が表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.termsOfService()));
        await tester.pumpAndSettle();

        expect(find.textContaining('最終更新日'), findsOneWidget);
      });

      testWidgets('先頭セクションの見出しが表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.termsOfService()));
        await tester.pumpAndSettle();

        expect(find.textContaining('第1条'), findsOneWidget);
      });
    });

    group('プライバシーポリシー画面', () {
      testWidgets('タイトルが表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.privacyPolicy()));
        await tester.pumpAndSettle();

        expect(find.text('プライバシーポリシー'), findsOneWidget);
      });

      testWidgets('最終更新日が表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.privacyPolicy()));
        await tester.pumpAndSettle();

        expect(find.textContaining('最終更新日'), findsOneWidget);
      });

      testWidgets('先頭セクションの見出しが表示される', (tester) async {
        await tester.pumpWidget(buildTestApp(LegalScreen.privacyPolicy()));
        await tester.pumpAndSettle();

        expect(find.textContaining('取得する情報'), findsOneWidget);
      });
    });
  });
}
