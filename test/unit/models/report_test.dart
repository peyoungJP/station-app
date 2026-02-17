import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Report', () {
    group('コンストラクタ', () {
      test('全フィールドが正しく設定される', () {
        final report = TestFixtures.report(
          id: 'r1',
          contentType: 'post',
          contentId: 'p1',
          reason: '誹謗中傷',
          details: '詳細説明',
        );

        expect(report.id, 'r1');
        expect(report.contentType, 'post');
        expect(report.contentId, 'p1');
        expect(report.reason, '誹謗中傷');
        expect(report.details, '詳細説明');
      });

      test('detailsを省略した場合、nullになる', () {
        final report = TestFixtures.report(details: null);

        expect(report.details, isNull);
      });
    });

    group('toJson', () {
      test('正しいJSON Mapが生成される', () {
        final report = TestFixtures.report(
          id: 'r-1',
          contentType: 'thread',
          contentId: 't-1',
          reason: 'スパム・宣伝',
          details: '宣伝目的の投稿',
        );

        final json = report.toJson();

        expect(json['id'], 'r-1');
        expect(json['content_type'], 'thread');
        expect(json['content_id'], 't-1');
        expect(json['reason'], 'スパム・宣伝');
        expect(json['details'], '宣伝目的の投稿');
      });

      test('detailsがnullの場合、JSONにnullが含まれる', () {
        final report = TestFixtures.report(details: null);
        final json = report.toJson();

        expect(json.containsKey('details'), isTrue);
        expect(json['details'], isNull);
      });

      test('contentTypeがthreadの場合、正しく出力される', () {
        final report = TestFixtures.report(contentType: 'thread');
        final json = report.toJson();

        expect(json['content_type'], 'thread');
      });

      test('contentTypeがpostの場合、正しく出力される', () {
        final report = TestFixtures.report(contentType: 'post');
        final json = report.toJson();

        expect(json['content_type'], 'post');
      });
    });
  });
}
