import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/utils/input_sanitizer.dart';

void main() {
  group('InputSanitizer', () {
    group('HTMLタグの除去', () {
      test('scriptタグが除去され、中身はテキストとして残る', () {
        // タグを除去し中身は無害なテキストとして保持する
        // Flutterはテキスト表示のみでJSを実行しないため安全
        final result =
            InputSanitizer.sanitize('<script>alert(1)</script>こんにちは');
        expect(result, 'alert(1)こんにちは');
      });

      test('imgタグが除去される', () {
        final result = InputSanitizer.sanitize('<img src="x" onerror="alert(1)">テスト');
        expect(result, 'テスト');
      });

      test('boldタグが除去されテキストは残る', () {
        final result = InputSanitizer.sanitize('<b>太字</b>テスト');
        expect(result, '太字テスト');
      });

      test('ネストしたHTMLタグが除去される', () {
        final result = InputSanitizer.sanitize('<div><p>テスト</p></div>');
        expect(result, 'テスト');
      });

      test('HTMLタグがない場合は変更されない', () {
        final result = InputSanitizer.sanitize('普通のテキスト');
        expect(result, '普通のテキスト');
      });
    });

    group('制御文字の除去', () {
      test('null文字（\\x00）が除去される', () {
        final result = InputSanitizer.sanitize('Hello\x00World');
        expect(result, 'HelloWorld');
      });

      test('バックスペース（\\x08）が除去される', () {
        final result = InputSanitizer.sanitize('テスト\x08文字');
        expect(result, 'テスト文字');
      });

      test('改行（\\n）は保持される', () {
        final result = InputSanitizer.sanitize('1行目\n2行目');
        expect(result, '1行目\n2行目');
      });

      test('タブ（\\t）は保持される', () {
        final result = InputSanitizer.sanitize('列1\t列2');
        expect(result, '列1\t列2');
      });
    });

    group('改行の正規化', () {
      test('3つ以上の連続改行が2つに正規化される', () {
        final result = InputSanitizer.sanitize('段落1\n\n\n\n段落2');
        expect(result, '段落1\n\n段落2');
      });

      test('2つの改行はそのまま', () {
        final result = InputSanitizer.sanitize('段落1\n\n段落2');
        expect(result, '段落1\n\n段落2');
      });

      test('1つの改行はそのまま', () {
        final result = InputSanitizer.sanitize('1行目\n2行目');
        expect(result, '1行目\n2行目');
      });
    });

    group('前後の空白除去', () {
      test('前後の空白がtrimされる', () {
        final result = InputSanitizer.sanitize('  テスト  ');
        expect(result, 'テスト');
      });

      test('前後の改行がtrimされる', () {
        final result = InputSanitizer.sanitize('\nテスト\n');
        expect(result, 'テスト');
      });
    });

    group('正常な入力の保持', () {
      test('日本語テキストは変更されない', () {
        const text = '今日は良い天気ですね。駅の掲示板に書いてみました！';
        final result = InputSanitizer.sanitize(text);
        expect(result, text);
      });

      test('絵文字は保持される', () {
        final result = InputSanitizer.sanitize('楽しかった🎉');
        expect(result, '楽しかった🎉');
      });

      test('空文字はそのまま空文字になる', () {
        final result = InputSanitizer.sanitize('');
        expect(result, '');
      });

      test('空白のみの場合、trimされて空文字になる', () {
        final result = InputSanitizer.sanitize('   ');
        expect(result, '');
      });
    });
  });
}
