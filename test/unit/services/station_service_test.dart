import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/station_service.dart';

void main() {
  group('StationService（モックモード）', () {
    late StationService service;

    setUp(() {
      service = StationService();
    });

    test('getNearbyStationsで3件のモックデータが返る', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      expect(stations.length, 3);
    });

    test('モックデータに東京駅が含まれる', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      expect(stations.any((s) => s.name == '東京'), isTrue);
    });

    test('モックデータに有楽町駅が含まれる', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      expect(stations.any((s) => s.name == '有楽町'), isTrue);
    });

    test('モックデータに神田駅が含まれる', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      expect(stations.any((s) => s.name == '神田'), isTrue);
    });

    test('各駅にdistanceが設定されている', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      for (final station in stations) {
        expect(station.distance, isNotNull);
        expect(station.distance, greaterThan(0));
      }
    });

    test('各駅にidが設定されている', () async {
      final stations = await service.getNearbyStations(
        latitude: 35.6812,
        longitude: 139.7671,
      );

      for (final station in stations) {
        expect(station.id, isNotEmpty);
      }
    });

    test('任意の座標を渡しても同じモックデータが返る', () async {
      final stations = await service.getNearbyStations(
        latitude: 0,
        longitude: 0,
      );

      expect(stations.length, 3);
    });
  });
}
