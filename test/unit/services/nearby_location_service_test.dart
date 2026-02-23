import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/location.dart';
import 'package:my_first_app/services/nearby_location_service.dart';

void main() {
  group('NearbyLocationService', () {
    late NearbyLocationService service;

    setUp(() {
      service = NearbyLocationService();
    });

    group('getNearbyLocations（モックモード）', () {
      test('近隣のLocationリストが返される', () async {
        final result = await service.getNearbyLocations(
          latitude: 35.6812,
          longitude: 139.7671,
        );

        expect(result, isNotEmpty);
      });

      test('mock-1〜mock-3のstation型が含まれる', () async {
        final result = await service.getNearbyLocations(
          latitude: 35.6812,
          longitude: 139.7671,
        );

        final ids = result.map((l) => l.id).toList();
        expect(ids, containsAll(['mock-1', 'mock-2', 'mock-3']));

        for (final loc in result.where((l) => l.type == LocationType.station)) {
          expect(loc.lineName, isNotNull);
          expect(loc.prefecture, isNotNull);
        }
      });

      test('event型のLocationが含まれる', () async {
        final result = await service.getNearbyLocations(
          latitude: 35.6812,
          longitude: 139.7671,
        );

        final events = result.where((l) => l.type == LocationType.event);
        expect(events, isNotEmpty);
      });

      test('全件にdistanceが設定されている', () async {
        final result = await service.getNearbyLocations(
          latitude: 35.6812,
          longitude: 139.7671,
        );

        for (final loc in result) {
          expect(loc.distance, isNotNull);
        }
      });
    });
  });
}
