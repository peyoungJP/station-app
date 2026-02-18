import 'package:flutter/foundation.dart';

import '../models/post.dart';
import '../utils/input_sanitizer.dart';
import 'supabase_service.dart';

class PostService {
  final Map<String, List<Post>> _mockPosts = {};

  PostService() {
    _initMockData();
  }

  void _initMockData() {
    _mockPosts['thread-1'] = [
      Post(
        id: 'post-1',
        threadId: 'thread-1',
        body: '八重洲口のラーメンストリートがおすすめです！',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Post(
        id: 'post-2',
        threadId: 'thread-1',
        body: 'KITTEの地下にも美味しいお店が多いですよ。',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      Post(
        id: 'post-3',
        threadId: 'thread-1',
        body: '丸ビルの5階のレストラン街も良いです。ちょっと高めですが。',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ];
    _mockPosts['thread-2'] = [
      Post(
        id: 'post-4',
        threadId: 'thread-2',
        body: '現在10分程度の遅れが出ているようです。',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      Post(
        id: 'post-5',
        threadId: 'thread-2',
        body: '新宿方面は通常運行に戻ったみたいです。',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  Future<List<Post>> getPosts(String threadId) async {
    if (SupabaseService.useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockPosts[threadId] ?? [];
    }

    final response = await SupabaseService.client
        .from('posts')
        .select()
        .eq('thread_id', threadId)
        .order('created_at');

    return (response as List)
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Post> createPost({
    required String threadId,
    required String body,
  }) async {
    final sanitizedBody = InputSanitizer.sanitize(body);

    if (SupabaseService.useMock) {
      final post = Post(
        id: 'post-${UniqueKey().hashCode}',
        threadId: threadId,
        body: sanitizedBody,
        createdAt: DateTime.now(),
      );
      _mockPosts.putIfAbsent(threadId, () => []);
      _mockPosts[threadId]!.add(post);
      return post;
    }

    final response = await SupabaseService.client
        .from('posts')
        .insert({
          'thread_id': threadId,
          'body': sanitizedBody,
        })
        .select()
        .single();

    // 投稿後にスレッドの last_posted_at を更新する
    // Note: DB トリガーで代替することを推奨
    await SupabaseService.client
        .from('threads')
        .update({'last_posted_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', threadId);

    return Post.fromJson(response);
  }
}
