import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/post.dart';
import '../models/thread.dart';
import '../services/post_service.dart';
import '../services/thread_service.dart';

final threadServiceProvider = Provider((ref) => ThreadService());
final postServiceProvider = Provider((ref) => PostService());

final threadsProvider = AsyncNotifierProvider.family<ThreadsNotifier,
    List<Thread>, String>(ThreadsNotifier.new);

class ThreadsNotifier extends FamilyAsyncNotifier<List<Thread>, String> {
  @override
  Future<List<Thread>> build(String arg) async {
    final service = ref.read(threadServiceProvider);
    return await service.getThreads(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(threadServiceProvider);
      return await service.getThreads(arg);
    });
  }

  Future<void> createThread({
    required String title,
    required String body,
  }) async {
    final service = ref.read(threadServiceProvider);
    await service.createThread(
      stationId: arg,
      title: title,
      body: body,
    );
    await refresh();
  }
}

final postsProvider =
    AsyncNotifierProvider.family<PostsNotifier, List<Post>, String>(
        PostsNotifier.new);

class PostsNotifier extends FamilyAsyncNotifier<List<Post>, String> {
  @override
  Future<List<Post>> build(String arg) async {
    final service = ref.read(postServiceProvider);
    return await service.getPosts(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(postServiceProvider);
      return await service.getPosts(arg);
    });
  }

  Future<void> addPost({required String body}) async {
    final service = ref.read(postServiceProvider);
    await service.createPost(threadId: arg, body: body);
    await refresh();
  }
}
