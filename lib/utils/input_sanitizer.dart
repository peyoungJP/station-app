class InputSanitizer {
  InputSanitizer._();

  /// ユーザー入力をサニタイズして返す。
  ///
  /// - HTMLタグを除去する
  /// - 制御文字（改行・タブ以外）を除去する
  /// - 連続する3つ以上の改行を2つに正規化する
  /// - 前後の空白を除去する
  static String sanitize(String input) {
    var result = input;

    // HTMLタグを除去
    result = result.replaceAll(RegExp(r'<[^>]*>'), '');

    // 制御文字を除去（\t=\x09, \n=\x0A, \r=\x0D は保持）
    result = result.replaceAll(
      RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]'),
      '',
    );

    // 連続する改行を最大2つに正規化
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return result.trim();
  }
}
