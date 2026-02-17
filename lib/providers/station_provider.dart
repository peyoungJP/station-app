import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/station.dart';
import '../services/station_service.dart';
import 'location_provider.dart';

final stationServiceProvider = Provider((ref) => StationService());

final nearbyStationsProvider =
    AsyncNotifierProvider<NearbyStationsNotifier, List<Station>>(
        NearbyStationsNotifier.new);

class NearbyStationsNotifier extends AsyncNotifier<List<Station>> {
  @override
  Future<List<Station>> build() async {
    return [];
  }

  Future<void> fetchNearbyStations() async {
    final location = ref.read(locationProvider).valueOrNull;
    if (location == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(stationServiceProvider);
      return await service.getNearbyStations(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    });
  }
}
