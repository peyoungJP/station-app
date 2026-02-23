import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/utils/ng_word_filter.dart';

void main() {
  group('NgWordFilter', () {
    group('NGワードが含まれる場合', () {
      test('死ねが含まれる場合、NgWordExceptionがスローされる', () {
        expect(
          () => NgWordFilter.check('お前死ね'),
          throwsA(isA<NgWordException>()),
        );
      });

      test('殺すが含まれる場合、NgWordExceptionがスローされる', () {
        expect(
          () => NgWordFilter.check('殺すぞ'),
          throwsA(isA<NgWordException>()),
        );
      });

      test('スパムワードが含まれる場合、NgWordExceptionがスローされる', () {
        expect(
          () => NgWordFilter.check('副業で月収100万円！'),
          throwsA(isA<NgWordException>()),
        );
      });

      test('出会い系が含まれる場合、NgWordExceptionがスローされる', () {
        expect(
          () => NgWordFilter.check('出会い系サイト'),
          throwsA(isA<NgWordException>()),
        );
      });

      test('NGワードが文章中に埋め込まれていても検出される', () {
        expect(
          () => NgWordFilter.check('今日は天気がいいね。でもお前死ねとか思ってないよ'),
          throwsA(isA<NgWordException>()),
        );
      });
    });

    group('NGワードが含まれない場合', () {
      test('正常な日本語テキストはスローしない', () {
        expect(
          () => NgWordFilter.check('東京駅周辺のおすすめランチを教えてください！'),
          returnsNormally,
        );
      });

      test('空文字はスローしない', () {
        expect(() => NgWordFilter.check(''), returnsNormally);
      });

      test('絵文字を含むテキストはスローしない', () {
        expect(
          () => NgWordFilter.check('楽しかった🎉 また来たい！'),
          returnsNormally,
        );
      });

      test('英数字を含む通常テキストはスローしない', () {
        expect(
          () => NgWordFilter.check('8番線ホームが混雑しています'),
          returnsNormally,
        );
      });
    });
  });
}
