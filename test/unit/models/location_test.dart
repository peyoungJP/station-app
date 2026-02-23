import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/location.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('station型のJSONから正しくデシリアライズされる', () {
        final json = {
          'id': 'loc-1',
          'type': 'station',
          'name': '東京',
          'latitude': 35.6812,
          'longitude': 139.7671,
          'radius_meters': 500,
          'is_active': true,
          'distance': 120.0,
          'prefecture': '東京都',
          'line_name': 'JR中央線',
        };

        final location = Location.fromJson(json);

        expect(location.id, 'loc-1');
        expect(location.type, LocationType.station);
        expect(location.name, '東京');
        expect(location.latitude, 35.6812);
        expect(location.longitude, 139.7671);
        expect(location.radiusMeters, 500);
        expect(location.isActive, true);
        expect(location.distance, 120.0);
        expect(location.prefecture, '東京都');
        expect(location.lineName, 'JR中央線');
        expect(location.startDate, isNull);
        expect(location.endDate, isNull);
      });

      test('event型のJSONから正しくデシリアライズされる', () {
        final json = {
          'id': 'loc-event-1',
          'type': 'event',
          'name': '森道市場2026',
          'latitude': 34.7,
          'longitude': 137.4,
          'radius_meters': 1000,
          'start_date': '2026-05-16T00:00:00.000',
          'end_date': '2026-05-18T00:00:00.000',
          'is_active': true,
        };

        final location = Location.fromJson(json);

        expect(location.type, LocationType.event);
        expect(location.name, '森道市場2026');
        expect(location.startDate, DateTime(2026, 5, 16));
        expect(location.endDate, DateTime(2026, 5, 18));
        expect(location.prefecture, isNull);
        expect(location.lineName, isNull);
      });

      test('distanceがnullの場合にnullになる', () {
        final json = {
          'id': 'loc-1',
          'type': 'station',
          'name': '東京',
          'latitude': 35.6812,
          'longitude': 139.7671,
        };

        final location = Location.fromJson(json);

        expect(location.distance, isNull);
      });

      test('radius_metersが省略された場合にデフォルト500になる', () {
        final json = {
          'id': 'loc-1',
          'type': 'station',
          'name': '東京',
          'latitude': 35.6812,
          'longitude': 139.7671,
        };

        final location = Location.fromJson(json);

        expect(location.radiusMeters, 500);
      });
    });

    group('toJson', () {
      test('station型が正しくシリアライズされる', () {
        final location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
          radiusMeters: 500,
          isActive: true,
          distance: 120.0,
          prefecture: '東京都',
          lineName: 'JR中央線',
        );

        final json = location.toJson();

        expect(json['id'], 'loc-1');
        expect(json['type'], 'station');
        expect(json['name'], '東京');
        expect(json['latitude'], 35.6812);
        expect(json['longitude'], 139.7671);
        expect(json['radius_meters'], 500);
        expect(json['is_active'], true);
        expect(json['prefecture'], '東京都');
        expect(json['line_name'], 'JR中央線');
        expect(json.containsKey('distance'), false);
      });

      test('distanceがtoJsonに含まれない', () {
        final location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
          distance: 200.0,
        );

        final json = location.toJson();

        expect(json.containsKey('distance'), false);
      });
    });

    group('copyWith', () {
      test('distanceのみ変更できる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
        );

        final updated = location.copyWith(distance: 200.0);

        expect(updated.distance, 200.0);
        expect(updated.id, 'loc-1');
        expect(updated.name, '東京');
      });

      test('全フィールドを変更できる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
        );

        final updated = location.copyWith(
          id: 'loc-2',
          type: LocationType.event,
          name: '森道市場',
          latitude: 34.7,
          longitude: 137.4,
          radiusMeters: 1000,
          isActive: false,
        );

        expect(updated.id, 'loc-2');
        expect(updated.type, LocationType.event);
        expect(updated.name, '森道市場');
        expect(updated.latitude, 34.7);
        expect(updated.longitude, 137.4);
        expect(updated.radiusMeters, 1000);
        expect(updated.isActive, false);
      });
    });

    group('displayTitle', () {
      test('station型の場合、「〜駅」になる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
        );

        expect(location.displayTitle, '東京駅');
      });

      test('event型の場合、nameそのままになる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.event,
          name: '森道市場2026',
          latitude: 34.7,
          longitude: 137.4,
        );

        expect(location.displayTitle, '森道市場2026');
      });

      test('area型の場合、nameそのままになる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.area,
          name: '渋谷エリア',
          latitude: 35.6,
          longitude: 139.7,
        );

        expect(location.displayTitle, '渋谷エリア');
      });
    });

    group('subtitle', () {
      test('station型の場合、lineNameになる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.station,
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
          lineName: 'JR中央線',
        );

        expect(location.subtitle, 'JR中央線');
      });

      test('event型でstartDate/endDateがある場合、日付範囲になる', () {
        final location = Location(
          id: 'loc-1',
          type: LocationType.event,
          name: '森道市場2026',
          latitude: 34.7,
          longitude: 137.4,
          startDate: DateTime(2026, 5, 16),
          endDate: DateTime(2026, 5, 18),
        );

        expect(location.subtitle, '5/16〜5/18');
      });

      test('event型でstartDate/endDateがない場合、nullになる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.event,
          name: '森道市場2026',
          latitude: 34.7,
          longitude: 137.4,
        );

        expect(location.subtitle, isNull);
      });

      test('area型の場合、nullになる', () {
        const location = Location(
          id: 'loc-1',
          type: LocationType.area,
          name: '渋谷エリア',
          latitude: 35.6,
          longitude: 139.7,
        );

        expect(location.subtitle, isNull);
      });
    });
  });
}
