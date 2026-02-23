import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';
import '../services/nearby_location_service.dart';
import 'location_provider.dart';

final nearbyLocationServiceProvider =
    Provider((ref) => NearbyLocationService());

final nearbyLocationsProvider =
    AsyncNotifierProvider<NearbyLocationsNotifier, List<Location>>(
        NearbyLocationsNotifier.new);

class NearbyLocationsNotifier extends AsyncNotifier<List<Location>> {
  @override
  Future<List<Location>> build() async {
    return [];
  }

  Future<void> fetchNearbyLocations() async {
    final location = ref.read(locationProvider).valueOrNull;
    if (location == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(nearbyLocationServiceProvider);
      return await service.getNearbyLocations(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    });
  }
}
