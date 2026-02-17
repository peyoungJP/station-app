import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/services/location_service.dart';

void main() {
  group('LocationService.calculateDistance', () {
    test('東京駅と有楽町駅の距離が約750〜850mになる', () {
      // 東京駅: 35.6812, 139.7671
      // 有楽町駅: 35.6748, 139.7630
      final distance = LocationService.calculateDistance(
        35.6812, 139.7671,
        35.6748, 139.7630,
      );

      expect(distance, greaterThan(750));
      expect(distance, lessThan(850));
    });

    test('東京駅と新宿駅の距離が約6〜7kmになる', () {
      // 東京駅: 35.6812, 139.7671
      // 新宿駅: 35.6896, 139.7006
      final distance = LocationService.calculateDistance(
        35.6812, 139.7671,
        35.6896, 139.7006,
      );

      expect(distance, greaterThan(6000));
      expect(distance, lessThan(7000));
    });

    test('同一座標の場合、距離が0になる', () {
      final distance = LocationService.calculateDistance(
        35.6812, 139.7671,
        35.6812, 139.7671,
      );

      expect(distance, 0.0);
    });

    test('緯度のみ異なる場合、正の距離が返る', () {
      final distance = LocationService.calculateDistance(
        35.0, 139.0,
        36.0, 139.0,
      );

      // 緯度1度 ≒ 約111km
      expect(distance, greaterThan(110000));
      expect(distance, lessThan(112000));
    });

    test('経度のみ異なる場合、正の距離が返る', () {
      final distance = LocationService.calculateDistance(
        35.0, 139.0,
        35.0, 140.0,
      );

      // 北緯35度での経度1度 ≒ 約91km
      expect(distance, greaterThan(90000));
      expect(distance, lessThan(92000));
    });

    test('引数の順序を入れ替えても同じ距離になる', () {
      final distance1 = LocationService.calculateDistance(
        35.6812, 139.7671,
        35.6748, 139.7630,
      );
      final distance2 = LocationService.calculateDistance(
        35.6748, 139.7630,
        35.6812, 139.7671,
      );

      expect(distance1, closeTo(distance2, 0.001));
    });

    test('非常に近い2点の距離が正しく計算される', () {
      // 約10m離れた2点
      final distance = LocationService.calculateDistance(
        35.681200, 139.767100,
        35.681290, 139.767100,
      );

      expect(distance, greaterThan(5));
      expect(distance, lessThan(15));
    });
  });
}
