/// NGワードが含まれていた場合にスローされる例外。
class NgWordException implements Exception {
  const NgWordException();
}

/// ユーザー投稿のNGワードチェックを行うユーティリティ。
///
/// NGワードが検出された場合は [NgWordException] をスローする。
/// リストは将来的に Supabase テーブルへ移行することを想定しているが、
/// MVP 段階ではクライアントサイドの固定リストを使用する。
class NgWordFilter {
  NgWordFilter._();

  static const List<String> _ngWords = [
    // 脅迫・暴力
    '死ね',
    '殺す',
    '殺すぞ',
    '爆破',
    '爆殺',
    // 差別・ヘイト
    'キモい死ね',
    'うせろ死ね',
    // スパム
    '副業で月収',
    '簡単に稼げる',
    '出会い系',
    'line交換',
    'ライン交換',
  ];

  /// テキストにNGワードが含まれているか確認する。
  ///
  /// 含まれている場合は [NgWordException] をスローする。
  /// 大文字・小文字を区別しない（ASCII範囲のみ）。
  static void check(String text) {
    final lower = text.toLowerCase();
    for (final word in _ngWords) {
      if (lower.contains(word.toLowerCase())) {
        throw const NgWordException();
      }
    }
  }
}
