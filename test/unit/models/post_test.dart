import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/post.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Post', () {
    group('コンストラクタ', () {
      test('全フィールドが正しく設定される', () {
        final createdAt = DateTime(2026, 1, 20, 14, 0);
        final post = Post(
          id: 'p1',
          threadId: 't1',
          body: '返信テスト',
          createdAt: createdAt,
        );

        expect(post.id, 'p1');
        expect(post.threadId, 't1');
        expect(post.body, '返信テスト');
        expect(post.createdAt, createdAt);
      });
    });

    group('fromJson', () {
      test('正常なJSONからPostが生成される', () {
        final json = TestFixtures.postJson(
          id: 'p-1',
          threadId: 't-1',
          body: 'おすすめです！',
          createdAt: '2026-02-10T15:30:00.000',
        );

        final post = Post.fromJson(json);

        expect(post.id, 'p-1');
        expect(post.threadId, 't-1');
        expect(post.body, 'おすすめです！');
        expect(post.createdAt, DateTime(2026, 2, 10, 15, 30));
      });
    });

    group('toJson', () {
      test('正しいJSON Mapが生成される', () {
        final post = TestFixtures.post(
          id: 'p-1',
          threadId: 't-1',
          body: '返信内容',
          createdAt: DateTime(2026, 4, 1, 8, 0),
        );

        final json = post.toJson();

        expect(json['id'], 'p-1');
        expect(json['thread_id'], 't-1');
        expect(json['body'], '返信内容');
        expect(json['created_at'], '2026-04-01T08:00:00.000');
      });
    });

    group('toJson → fromJson 往復', () {
      test('シリアライズ→デシリアライズで全フィールドが保持される', () {
        final original = TestFixtures.post(
          id: 'rt-1',
          threadId: 'rt-t1',
          body: '往復テスト返信',
          createdAt: DateTime(2026, 5, 20, 22, 15),
        );

        final restored = Post.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.threadId, original.threadId);
        expect(restored.body, original.body);
        expect(restored.createdAt, original.createdAt);
      });
    });
  });
}
