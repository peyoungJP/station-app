import '../models/location.dart';
import 'supabase_service.dart';

class NearbyLocationService {
  Future<List<Location>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radiusMeters = 500,
  }) async {
    if (SupabaseService.useMock) {
      return _getMockLocations(latitude, longitude);
    }

    final response = await SupabaseService.client.rpc(
      'get_nearby_locations',
      params: {
        'lat': latitude,
        'lng': longitude,
        'radius_meters': radiusMeters.toInt(),
      },
    );

    return (response as List)
        .map((json) => Location.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<Location> _getMockLocations(double lat, double lng) {
    return [
      const Location(
        id: 'mock-1',
        type: LocationType.station,
        name: '東京',
        latitude: 35.6812,
        longitude: 139.7671,
        prefecture: '東京都',
        lineName: 'JR中央線',
        distance: 120,
      ),
      const Location(
        id: 'mock-2',
        type: LocationType.station,
        name: '有楽町',
        latitude: 35.6748,
        longitude: 139.7630,
        prefecture: '東京都',
        lineName: 'JR山手線',
        distance: 350,
      ),
      const Location(
        id: 'mock-3',
        type: LocationType.station,
        name: '神田',
        latitude: 35.6918,
        longitude: 139.7709,
        prefecture: '東京都',
        lineName: 'JR京浜東北線',
        distance: 480,
      ),
      Location(
        id: 'mock-event-1',
        type: LocationType.event,
        name: '森道市場2026',
        latitude: 34.7,
        longitude: 137.4,
        radiusMeters: 1000,
        startDate: DateTime(2026, 5, 16),
        endDate: DateTime(2026, 5, 18),
        distance: 300,
      ),
    ];
  }
}
