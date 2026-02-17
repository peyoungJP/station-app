import 'package:geolocator/geolocator.dart';
import 'package:my_first_app/models/post.dart';
import 'package:my_first_app/models/station.dart';
import 'package:my_first_app/models/thread.dart';
import 'package:my_first_app/services/location_service.dart';
import 'package:my_first_app/services/post_service.dart';
import 'package:my_first_app/services/station_service.dart';
import 'package:my_first_app/services/thread_service.dart';

import 'fixtures.dart';

class MockLocationService extends LocationService {
  bool permissionGranted = true;
  bool shouldThrow = false;
  Position mockPosition = Position(
    latitude: 35.6812,
    longitude: 139.7671,
    timestamp: DateTime(2026, 1, 1),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  Future<bool> requestPermission() async {
    if (shouldThrow) throw Exception('テストエラー');
    return permissionGranted;
  }

  @override
  Future<bool> checkPermission() async {
    return permissionGranted;
  }

  @override
  Future<Position> getCurrentPosition() async {
    if (shouldThrow) throw Exception('テストエラー');
    return mockPosition;
  }
}

class MockStationService extends StationService {
  List<Station> mockResult = [TestFixtures.station()];
  bool shouldThrow = false;

  @override
  Future<List<Station>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusMeters = 500,
  }) async {
    if (shouldThrow) throw Exception('テストエラー');
    return mockResult;
  }
}

class MockThreadService extends ThreadService {
  List<Thread> mockResult = [TestFixtures.thread()];
  bool shouldThrow = false;
  final List<Thread> createdThreads = [];

  @override
  Future<List<Thread>> getThreads(String stationId) async {
    if (shouldThrow) throw Exception('テストエラー');
    return mockResult;
  }

  @override
  Future<Thread> createThread({
    required String stationId,
    required String title,
    required String body,
  }) async {
    if (shouldThrow) throw Exception('テストエラー');
    final thread = TestFixtures.thread(
      stationId: stationId,
      title: title,
      body: body,
    );
    createdThreads.add(thread);
    mockResult = [thread, ...mockResult];
    return thread;
  }
}

class MockPostService extends PostService {
  List<Post> mockResult = [TestFixtures.post()];
  bool shouldThrow = false;
  final List<Post> createdPosts = [];

  @override
  Future<List<Post>> getPosts(String threadId) async {
    if (shouldThrow) throw Exception('テストエラー');
    return mockResult;
  }

  @override
  Future<Post> createPost({
    required String threadId,
    required String body,
  }) async {
    if (shouldThrow) throw Exception('テストエラー');
    final post = TestFixtures.post(threadId: threadId, body: body);
    createdPosts.add(post);
    mockResult = [...mockResult, post];
    return post;
  }
}
