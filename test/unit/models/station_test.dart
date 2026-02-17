import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/station.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('Station', () {
    group('コンストラクタ', () {
      test('全フィールドが正しく設定される', () {
        const station = Station(
          id: 's1',
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
          prefecture: '東京都',
          lineName: 'JR中央線',
          distance: 120,
        );

        expect(station.id, 's1');
        expect(station.name, '東京');
        expect(station.latitude, 35.6812);
        expect(station.longitude, 139.7671);
        expect(station.prefecture, '東京都');
        expect(station.lineName, 'JR中央線');
        expect(station.distance, 120);
      });

      test('distanceを省略した場合、nullになる', () {
        const station = Station(
          id: 's1',
          name: '東京',
          latitude: 35.6812,
          longitude: 139.7671,
          prefecture: '東京都',
          lineName: 'JR中央線',
        );

        expect(station.distance, isNull);
      });
    });

    group('fromJson', () {
      test('正常なJSONからStationが生成される', () {
        final json = TestFixtures.stationJson(
          id: 'st-1',
          name: '渋谷',
          latitude: 35.6580,
          longitude: 139.7016,
          prefecture: '東京都',
          lineName: 'JR山手線',
          distance: 250,
        );

        final station = Station.fromJson(json);

        expect(station.id, 'st-1');
        expect(station.name, '渋谷');
        expect(station.latitude, 35.6580);
        expect(station.longitude, 139.7016);
        expect(station.prefecture, '東京都');
        expect(station.lineName, 'JR山手線');
        expect(station.distance, 250);
      });

      test('distanceがnullの場合、nullのまま保持される', () {
        final json = TestFixtures.stationJson(distance: null);
        json.remove('distance');

        final station = Station.fromJson(json);

        expect(station.distance, isNull);
      });

      test('latitudeがintで渡されてもdoubleに変換される', () {
        final json = TestFixtures.stationJson();
        json['latitude'] = 35;

        final station = Station.fromJson(json);

        expect(station.latitude, 35.0);
        expect(station.latitude, isA<double>());
      });

      test('distanceがintで渡されてもdoubleに変換される', () {
        final json = TestFixtures.stationJson(distance: null);
        json['distance'] = 100;

        final station = Station.fromJson(json);

        expect(station.distance, 100.0);
        expect(station.distance, isA<double>());
      });
    });

    group('toJson', () {
      test('正しいJSON Mapが生成される', () {
        final station = TestFixtures.station(
          id: 'st-1',
          name: '新宿',
          latitude: 35.6896,
          longitude: 139.7006,
          prefecture: '東京都',
          lineName: 'JR中央線',
        );

        final json = station.toJson();

        expect(json['id'], 'st-1');
        expect(json['name'], '新宿');
        expect(json['latitude'], 35.6896);
        expect(json['longitude'], 139.7006);
        expect(json['prefecture'], '東京都');
        expect(json['line_name'], 'JR中央線');
      });

      test('distanceはtoJsonに含まれない', () {
        final station = TestFixtures.station(distance: 500);
        final json = station.toJson();

        expect(json.containsKey('distance'), isFalse);
      });
    });

    group('toJson → fromJson 往復', () {
      test('シリアライズ→デシリアライズで主要フィールドが保持される', () {
        final original = TestFixtures.station(
          id: 'rt-1',
          name: '品川',
          latitude: 35.6284,
          longitude: 139.7387,
          prefecture: '東京都',
          lineName: 'JR東海道線',
        );

        final restored = Station.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.latitude, original.latitude);
        expect(restored.longitude, original.longitude);
        expect(restored.prefecture, original.prefecture);
        expect(restored.lineName, original.lineName);
      });
    });

    group('copyWith', () {
      test('distanceのみ変更され他のフィールドは維持される', () {
        final original = TestFixtures.station(distance: 100);
        final copied = original.copyWith(distance: 999);

        expect(copied.distance, 999);
        expect(copied.id, original.id);
        expect(copied.name, original.name);
        expect(copied.latitude, original.latitude);
        expect(copied.longitude, original.longitude);
        expect(copied.prefecture, original.prefecture);
        expect(copied.lineName, original.lineName);
      });

      test('distanceを指定しない場合、元の値が維持される', () {
        final original = TestFixtures.station(distance: 200);
        final copied = original.copyWith();

        expect(copied.distance, 200);
      });
    });
  });
}
