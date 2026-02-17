import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());

final locationProvider =
    AsyncNotifierProvider<LocationNotifier, Position?>(LocationNotifier.new);

class LocationNotifier extends AsyncNotifier<Position?> {
  @override
  Future<Position?> build() async {
    return null;
  }

  Future<void> fetchLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(locationServiceProvider);
      final hasPermission = await service.requestPermission();
      if (!hasPermission) {
        throw const LocationPermissionDeniedException();
      }
      return await service.getCurrentPosition();
    });
  }
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();

  @override
  String toString() => '位置情報の権限が許可されていません';
}
