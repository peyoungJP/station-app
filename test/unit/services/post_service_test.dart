import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/post_service.dart';

void main() {
  group('PostService（モックモード）', () {
    late PostService service;

    setUp(() {
      service = PostService();
    });

    group('getPosts', () {
      test('thread-1の投稿が3件返る', () async {
        final posts = await service.getPosts('thread-1');

        expect(posts.length, 3);
      });

      test('thread-2の投稿が2件返る', () async {
        final posts = await service.getPosts('thread-2');

        expect(posts.length, 2);
      });

      test('存在しないthreadIdの場合、空リストが返る', () async {
        final posts = await service.getPosts('non-existent');

        expect(posts, isEmpty);
      });

      test('各投稿にbodyが設定されている', () async {
        final posts = await service.getPosts('thread-1');

        for (final post in posts) {
          expect(post.body, isNotEmpty);
        }
      });

      test('各投稿にthreadIdが正しく設定されている', () async {
        final posts = await service.getPosts('thread-1');

        for (final post in posts) {
          expect(post.threadId, 'thread-1');
        }
      });
    });

    group('createPost', () {
      test('投稿が作成され、返り値に正しいbodyが含まれる', () async {
        final post = await service.createPost(
          threadId: 'thread-1',
          body: '新しい返信',
        );

        expect(post.body, '新しい返信');
        expect(post.threadId, 'thread-1');
      });

      test('作成後にgetPostsで取得すると件数が増えている', () async {
        final beforeCount = (await service.getPosts('thread-1')).length;

        await service.createPost(
          threadId: 'thread-1',
          body: '追加返信',
        );

        final afterCount = (await service.getPosts('thread-1')).length;
        expect(afterCount, beforeCount + 1);
      });

      test('作成した投稿がリストの末尾に追加される', () async {
        await service.createPost(
          threadId: 'thread-1',
          body: '末尾に来る返信',
        );

        final posts = await service.getPosts('thread-1');
        expect(posts.last.body, '末尾に来る返信');
      });

      test('存在しないthreadIdでも作成できる', () async {
        final post = await service.createPost(
          threadId: 'new-thread',
          body: '新スレッドへの返信',
        );

        expect(post.threadId, 'new-thread');

        final posts = await service.getPosts('new-thread');
        expect(posts.length, 1);
      });

      test('作成された投稿にidが割り振られる', () async {
        final post = await service.createPost(
          threadId: 'thread-1',
          body: 'IDテスト',
        );

        expect(post.id, isNotEmpty);
      });
    });
  });
}
