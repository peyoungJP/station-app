import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/thread_service.dart';
import 'package:my_first_app/utils/ng_word_filter.dart';

void main() {
  group('ThreadService（モックモード）', () {
    late ThreadService service;

    setUp(() {
      service = ThreadService();
    });

    group('getThreads', () {
      test('mock-1のスレッドが3件返る', () async {
        final threads = await service.getThreads('mock-1');

        expect(threads.length, 3);
      });

      test('mock-2のスレッドが1件返る', () async {
        final threads = await service.getThreads('mock-2');

        expect(threads.length, 1);
      });

      test('mock-3のスレッドが0件返る', () async {
        final threads = await service.getThreads('mock-3');

        expect(threads, isEmpty);
      });

      test('存在しないstationIdの場合、空リストが返る', () async {
        final threads = await service.getThreads('non-existent');

        expect(threads, isEmpty);
      });

      test('mock-1のスレッドにタイトルが設定されている', () async {
        final threads = await service.getThreads('mock-1');

        for (final thread in threads) {
          expect(thread.title, isNotEmpty);
        }
      });

      test('mock-1のスレッドにstationIdが正しく設定されている', () async {
        final threads = await service.getThreads('mock-1');

        for (final thread in threads) {
          expect(thread.stationId, 'mock-1');
        }
      });

      test('スレッドがlastPostedAt降順でソートされている', () async {
        final threads = await service.getThreads('mock-1');

        for (int i = 0; i < threads.length - 1; i++) {
          final aTime = threads[i].lastPostedAt ?? threads[i].createdAt;
          final bTime =
              threads[i + 1].lastPostedAt ?? threads[i + 1].createdAt;
          expect(aTime.isAfter(bTime) || aTime.isAtSameMomentAs(bTime),
              isTrue);
        }
      });
    });

    group('createThread', () {
      test('スレッドが作成され、返り値に正しいタイトルが含まれる', () async {
        final thread = await service.createThread(
          stationId: 'mock-1',
          title: '新しいスレッド',
          body: '新しい本文',
        );

        expect(thread.title, '新しいスレッド');
        expect(thread.body, '新しい本文');
        expect(thread.stationId, 'mock-1');
      });

      test('作成後にgetThreadsで取得すると件数が増えている', () async {
        final beforeCount = (await service.getThreads('mock-1')).length;

        await service.createThread(
          stationId: 'mock-1',
          title: '追加スレッド',
          body: '追加本文',
        );

        final afterCount = (await service.getThreads('mock-1')).length;
        expect(afterCount, beforeCount + 1);
      });

      test('作成したスレッドがリストの先頭に追加される', () async {
        await service.createThread(
          stationId: 'mock-1',
          title: '先頭に来るスレッド',
          body: '本文',
        );

        final threads = await service.getThreads('mock-1');
        expect(threads.first.title, '先頭に来るスレッド');
      });

      test('存在しないstationIdでも作成できる', () async {
        final thread = await service.createThread(
          stationId: 'new-station',
          title: '新駅スレッド',
          body: '本文',
        );

        expect(thread.stationId, 'new-station');

        final threads = await service.getThreads('new-station');
        expect(threads.length, 1);
      });

      test('作成されたスレッドにidが割り振られる', () async {
        final thread = await service.createThread(
          stationId: 'mock-1',
          title: 'IDテスト',
          body: '本文',
        );

        expect(thread.id, isNotEmpty);
      });

      test('作成されたスレッドにcreatedAtが設定される', () async {
        final before = DateTime.now();

        final thread = await service.createThread(
          stationId: 'mock-1',
          title: '日時テスト',
          body: '本文',
        );

        expect(thread.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      });

      test('タイトルにNGワードが含まれる場合、NgWordExceptionがスローされる', () async {
        expect(
          () => service.createThread(
            stationId: 'mock-1',
            title: '死ねと言われた',
            body: '普通の本文',
          ),
          throwsA(isA<NgWordException>()),
        );
      });

      test('本文にNGワードが含まれる場合、NgWordExceptionがスローされる', () async {
        expect(
          () => service.createThread(
            stationId: 'mock-1',
            title: '普通のタイトル',
            body: '副業で月収100万！',
          ),
          throwsA(isA<NgWordException>()),
        );
      });
    });
  });
}
