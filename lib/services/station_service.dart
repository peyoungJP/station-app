import '../models/station.dart';
import 'supabase_service.dart';

class StationService {
  Future<List<Station>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusMeters = 500,
  }) async {
    if (SupabaseService.useMock) {
      return _getMockStations(latitude, longitude);
    }

    final response = await SupabaseService.client.rpc(
      'get_nearby_stations',
      params: {
        'lat': latitude,
        'lng': longitude,
        'radius_meters': radiusMeters.toInt(),
      },
    );

    return (response as List)
        .map((json) => Station.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<Station> _getMockStations(double lat, double lng) {
    return [
      Station(
        id: 'mock-1',
        name: '東京',
        latitude: 35.6812,
        longitude: 139.7671,
        prefecture: '東京都',
        lineName: 'JR中央線',
        distance: 120,
      ),
      Station(
        id: 'mock-2',
        name: '有楽町',
        latitude: 35.6748,
        longitude: 139.7630,
        prefecture: '東京都',
        lineName: 'JR山手線',
        distance: 350,
      ),
      Station(
        id: 'mock-3',
        name: '神田',
        latitude: 35.6918,
        longitude: 139.7709,
        prefecture: '東京都',
        lineName: 'JR京浜東北線',
        distance: 480,
      ),
    ];
  }
}
