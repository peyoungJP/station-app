import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/providers/thread_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('ThreadsNotifier', () {
    late ProviderContainer container;
    late MockThreadService mockThreadService;

    setUp(() {
      mockThreadService = MockThreadService();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          threadServiceProvider.overrideWithValue(mockThreadService),
        ],
      );
    }

    test('build時にサービスからスレッド一覧が取得される', () async {
      mockThreadService.mockResult = [
        TestFixtures.thread(title: 'スレッド1'),
        TestFixtures.thread(id: 't2', title: 'スレッド2'),
      ];
      container = createContainer();

      final threads = await container.read(threadsProvider('station-1').future);

      expect(threads.length, 2);
      expect(threads.first.title, 'スレッド1');
    });

    test('サービスが空リストを返した場合、空リストになる', () async {
      mockThreadService.mockResult = [];
      container = createContainer();

      final threads = await container.read(threadsProvider('station-1').future);

      expect(threads, isEmpty);
    });

    test('サービスが例外を投げた場合、AsyncErrorになる', () async {
      mockThreadService.shouldThrow = true;
      container = createContainer();

      await expectLater(
        container.read(threadsProvider('station-1').future),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh後にデータが更新される', () async {
      mockThreadService.mockResult = [TestFixtures.thread(title: '初期')];
      container = createContainer();

      await container.read(threadsProvider('station-1').future);

      mockThreadService.mockResult = [
        TestFixtures.thread(title: '更新後1'),
        TestFixtures.thread(id: 't2', title: '更新後2'),
      ];

      await container.read(threadsProvider('station-1').notifier).refresh();

      final state = container.read(threadsProvider('station-1'));
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.length, 2);
      expect(state.valueOrNull!.first.title, '更新後1');
    });

    test('createThread後にリストが自動refreshされる', () async {
      mockThreadService.mockResult = [TestFixtures.thread(title: '既存')];
      container = createContainer();

      await container.read(threadsProvider('station-1').future);

      await container
          .read(threadsProvider('station-1').notifier)
          .createThread(title: '新規スレッド', body: '本文');

      final state = container.read(threadsProvider('station-1'));
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.any((t) => t.title == '新規スレッド'), isTrue);
    });

    test('createThreadでサービスのcreateThreadが呼ばれる', () async {
      mockThreadService.mockResult = [];
      container = createContainer();

      await container.read(threadsProvider('station-1').future);

      await container
          .read(threadsProvider('station-1').notifier)
          .createThread(title: '作成テスト', body: '本文テスト');

      expect(mockThreadService.createdThreads.length, 1);
      expect(mockThreadService.createdThreads.first.title, '作成テスト');
    });
  });

  group('PostsNotifier', () {
    late ProviderContainer container;
    late MockPostService mockPostService;

    setUp(() {
      mockPostService = MockPostService();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          postServiceProvider.overrideWithValue(mockPostService),
        ],
      );
    }

    test('build時にサービスから投稿一覧が取得される', () async {
      mockPostService.mockResult = [
        TestFixtures.post(body: '返信1'),
        TestFixtures.post(id: 'p2', body: '返信2'),
      ];
      container = createContainer();

      final posts = await container.read(postsProvider('thread-1').future);

      expect(posts.length, 2);
      expect(posts.first.body, '返信1');
    });

    test('サービスが空リストを返した場合、空リストになる', () async {
      mockPostService.mockResult = [];
      container = createContainer();

      final posts = await container.read(postsProvider('thread-1').future);

      expect(posts, isEmpty);
    });

    test('サービスが例外を投げた場合、AsyncErrorになる', () async {
      mockPostService.shouldThrow = true;
      container = createContainer();

      await expectLater(
        container.read(postsProvider('thread-1').future),
        throwsA(isA<Exception>()),
      );
    });

    test('refresh後にデータが更新される', () async {
      mockPostService.mockResult = [TestFixtures.post(body: '初期返信')];
      container = createContainer();

      await container.read(postsProvider('thread-1').future);

      mockPostService.mockResult = [
        TestFixtures.post(body: '更新後1'),
        TestFixtures.post(id: 'p2', body: '更新後2'),
      ];

      await container.read(postsProvider('thread-1').notifier).refresh();

      final state = container.read(postsProvider('thread-1'));
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.length, 2);
    });

    test('addPost後にリストが自動refreshされる', () async {
      mockPostService.mockResult = [TestFixtures.post(body: '既存返信')];
      container = createContainer();

      await container.read(postsProvider('thread-1').future);

      await container
          .read(postsProvider('thread-1').notifier)
          .addPost(body: '新しい返信');

      final state = container.read(postsProvider('thread-1'));
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.any((p) => p.body == '新しい返信'), isTrue);
    });

    test('addPostでサービスのcreatePostが呼ばれる', () async {
      mockPostService.mockResult = [];
      container = createContainer();

      await container.read(postsProvider('thread-1').future);

      await container
          .read(postsProvider('thread-1').notifier)
          .addPost(body: '投稿テスト');

      expect(mockPostService.createdPosts.length, 1);
      expect(mockPostService.createdPosts.first.body, '投稿テスト');
    });
  });
}
