import 'package:flutter/foundation.dart';

import '../models/thread.dart';
import '../utils/input_sanitizer.dart';
import '../utils/ng_word_filter.dart';
import 'supabase_service.dart';

class ThreadService {
  final Map<String, List<Thread>> _mockThreads = {};

  ThreadService() {
    _initMockData();
  }

  void _initMockData() {
    _mockThreads['mock-1'] = [
      Thread(
        id: 'thread-1',
        stationId: 'mock-1',
        title: '東京駅周辺のおすすめランチ',
        body: '東京駅周辺で美味しいランチのお店を教えてください！',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        postCount: 5,
        lastPostedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Thread(
        id: 'thread-2',
        stationId: 'mock-1',
        title: '中央線の遅延情報',
        body: '本日の中央線の運行状況について共有しましょう。',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        postCount: 12,
        lastPostedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Thread(
        id: 'thread-3',
        stationId: 'mock-1',
        title: '丸の内のイベント情報',
        body: '今週末の丸の内エリアのイベント情報をまとめます。',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        postCount: 3,
        lastPostedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ];
    _mockThreads['mock-2'] = [
      Thread(
        id: 'thread-4',
        stationId: 'mock-2',
        title: '有楽町マルイのセール情報',
        body: '有楽町マルイで開催中のセール情報を共有します。',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        postCount: 2,
        lastPostedAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
    ];
    _mockThreads['mock-3'] = [];
  }

  Future<List<Thread>> getThreads(String stationId) async {
    if (SupabaseService.useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      final threads = List<Thread>.from(_mockThreads[stationId] ?? []);
      threads.sort((a, b) {
        final aTime = a.lastPostedAt ?? a.createdAt;
        final bTime = b.lastPostedAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      return threads;
    }

    // DB側で last_posted_at は posts 挿入時のトリガーで更新される想定
    // Migration: ALTER TABLE threads ADD COLUMN last_posted_at timestamptz;
    final response = await SupabaseService.client
        .from('threads')
        .select()
        .eq('station_id', stationId)
        .order('last_posted_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Thread.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Thread> createThread({
    required String stationId,
    required String title,
    required String body,
  }) async {
    final sanitizedTitle = InputSanitizer.sanitize(title);
    final sanitizedBody = InputSanitizer.sanitize(body);

    NgWordFilter.check(sanitizedTitle);
    NgWordFilter.check(sanitizedBody);

    if (SupabaseService.useMock) {
      final thread = Thread(
        id: 'thread-${UniqueKey().hashCode}',
        stationId: stationId,
        title: sanitizedTitle,
        body: sanitizedBody,
        createdAt: DateTime.now(),
      );
      _mockThreads.putIfAbsent(stationId, () => []);
      _mockThreads[stationId]!.insert(0, thread);
      return thread;
    }

    final response = await SupabaseService.client
        .from('threads')
        .insert({
          'station_id': stationId,
          'title': sanitizedTitle,
          'body': sanitizedBody,
        })
        .select()
        .single();

    return Thread.fromJson(response);
  }
}
