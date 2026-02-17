import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/thread.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Thread', () {
    group('コンストラクタ', () {
      test('全フィールドが正しく設定される', () {
        final createdAt = DateTime(2026, 1, 15, 10, 30);
        final thread = Thread(
          id: 't1',
          stationId: 's1',
          title: 'テストタイトル',
          body: 'テスト本文',
          createdAt: createdAt,
          postCount: 5,
        );

        expect(thread.id, 't1');
        expect(thread.stationId, 's1');
        expect(thread.title, 'テストタイトル');
        expect(thread.body, 'テスト本文');
        expect(thread.createdAt, createdAt);
        expect(thread.postCount, 5);
      });

      test('postCountを省略した場合、0になる', () {
        final thread = Thread(
          id: 't1',
          stationId: 's1',
          title: 'タイトル',
          body: '本文',
          createdAt: DateTime.now(),
        );

        expect(thread.postCount, 0);
      });
    });

    group('fromJson', () {
      test('正常なJSONからThreadが生成される', () {
        final json = TestFixtures.threadJson(
          id: 't-1',
          stationId: 's-1',
          title: 'ランチ情報',
          body: 'おすすめのお店を教えて',
          createdAt: '2026-02-01T09:00:00.000',
          postCount: 10,
        );

        final thread = Thread.fromJson(json);

        expect(thread.id, 't-1');
        expect(thread.stationId, 's-1');
        expect(thread.title, 'ランチ情報');
        expect(thread.body, 'おすすめのお店を教えて');
        expect(thread.createdAt, DateTime(2026, 2, 1, 9, 0));
        expect(thread.postCount, 10);
      });

      test('post_countがnullの場合、0になる', () {
        final json = TestFixtures.threadJson(postCount: 0);
        json['post_count'] = null;

        final thread = Thread.fromJson(json);

        expect(thread.postCount, 0);
      });

      test('post_countキーが存在しない場合、0になる', () {
        final json = TestFixtures.threadJson();
        json.remove('post_count');

        final thread = Thread.fromJson(json);

        expect(thread.postCount, 0);
      });
    });

    group('toJson', () {
      test('正しいJSON Mapが生成される', () {
        final thread = TestFixtures.thread(
          id: 't-1',
          stationId: 's-1',
          title: 'タイトル',
          body: '本文',
          createdAt: DateTime(2026, 3, 1, 12, 0),
        );

        final json = thread.toJson();

        expect(json['id'], 't-1');
        expect(json['station_id'], 's-1');
        expect(json['title'], 'タイトル');
        expect(json['body'], '本文');
        expect(json['created_at'], '2026-03-01T12:00:00.000');
      });

      test('postCountはtoJsonに含まれない', () {
        final thread = TestFixtures.thread(postCount: 5);
        final json = thread.toJson();

        expect(json.containsKey('post_count'), isFalse);
      });
    });

    group('toJson → fromJson 往復', () {
      test('シリアライズ→デシリアライズで主要フィールドが保持される', () {
        final original = TestFixtures.thread(
          id: 'rt-1',
          stationId: 'rs-1',
          title: '往復テスト',
          body: '往復テスト本文',
          createdAt: DateTime(2026, 6, 15, 18, 30),
        );

        final restored = Thread.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.stationId, original.stationId);
        expect(restored.title, original.title);
        expect(restored.body, original.body);
        expect(restored.createdAt, original.createdAt);
      });
    });
  });
}
