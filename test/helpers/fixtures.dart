import 'package:my_first_app/models/post.dart';
import 'package:my_first_app/models/report.dart';
import 'package:my_first_app/models/station.dart';
import 'package:my_first_app/models/thread.dart';

class TestFixtures {
  TestFixtures._();

  static Station station({
    String id = 'test-station-1',
    String name = 'テスト駅',
    double latitude = 35.6812,
    double longitude = 139.7671,
    String prefecture = '東京都',
    String lineName = 'テスト線',
    double? distance = 100,
  }) =>
      Station(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        prefecture: prefecture,
        lineName: lineName,
        distance: distance,
      );

  static Map<String, dynamic> stationJson({
    String id = 'test-station-1',
    String name = 'テスト駅',
    double latitude = 35.6812,
    double longitude = 139.7671,
    String prefecture = '東京都',
    String lineName = 'テスト線',
    double? distance = 100,
  }) =>
      {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'prefecture': prefecture,
        'line_name': lineName,
        if (distance != null) 'distance': distance,
      };

  static Thread thread({
    String id = 'test-thread-1',
    String stationId = 'test-station-1',
    String title = 'テストスレッド',
    String body = 'テスト本文です',
    DateTime? createdAt,
    int postCount = 0,
  }) =>
      Thread(
        id: id,
        stationId: stationId,
        title: title,
        body: body,
        createdAt: createdAt ?? DateTime(2026, 1, 1, 12, 0),
        postCount: postCount,
      );

  static Map<String, dynamic> threadJson({
    String id = 'test-thread-1',
    String stationId = 'test-station-1',
    String title = 'テストスレッド',
    String body = 'テスト本文です',
    String createdAt = '2026-01-01T12:00:00.000',
    int postCount = 0,
  }) =>
      {
        'id': id,
        'station_id': stationId,
        'title': title,
        'body': body,
        'created_at': createdAt,
        'post_count': postCount,
      };

  static Post post({
    String id = 'test-post-1',
    String threadId = 'test-thread-1',
    String body = 'テスト返信です',
    DateTime? createdAt,
  }) =>
      Post(
        id: id,
        threadId: threadId,
        body: body,
        createdAt: createdAt ?? DateTime(2026, 1, 1, 13, 0),
      );

  static Map<String, dynamic> postJson({
    String id = 'test-post-1',
    String threadId = 'test-thread-1',
    String body = 'テスト返信です',
    String createdAt = '2026-01-01T13:00:00.000',
  }) =>
      {
        'id': id,
        'thread_id': threadId,
        'body': body,
        'created_at': createdAt,
      };

  static Report report({
    String id = 'test-report-1',
    String contentType = 'thread',
    String contentId = 'test-thread-1',
    String reason = 'スパム・宣伝',
    String? details,
  }) =>
      Report(
        id: id,
        contentType: contentType,
        contentId: contentId,
        reason: reason,
        details: details,
      );
}
