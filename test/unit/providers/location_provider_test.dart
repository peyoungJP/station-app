import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/providers/location_provider.dart';

import '../../helpers/mock_services.dart';

void main() {
  group('LocationNotifier', () {
    late ProviderContainer container;
    late MockLocationService mockLocationService;

    setUp(() {
      mockLocationService = MockLocationService();
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(mockLocationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('初期状態はAsyncData(null)である', () async {
      // build()を待つ
      await container.read(locationProvider.future);

      final state = container.read(locationProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isNull);
    });

    test('fetchLocation成功時にPositionがAsyncDataに入る', () async {
      await container.read(locationProvider.future);
      await container.read(locationProvider.notifier).fetchLocation();

      final state = container.read(locationProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isNotNull);
      expect(state.valueOrNull!.latitude, 35.6812);
      expect(state.valueOrNull!.longitude, 139.7671);
    });

    test('位置情報の権限が拒否された場合、AsyncErrorになる', () async {
      mockLocationService.permissionGranted = false;

      await container.read(locationProvider.future);
      await container.read(locationProvider.notifier).fetchLocation();

      final state = container.read(locationProvider);
      expect(state, isA<AsyncError>());
      expect(state.error, isA<LocationPermissionDeniedException>());
    });

    test('LocationPermissionDeniedExceptionのtoStringが日本語メッセージを返す', () {
      const exception = LocationPermissionDeniedException();
      expect(exception.toString(), '位置情報の権限が許可されていません');
    });

    test('fetchLocationを2回呼んでも最新のPositionが保持される', () async {
      await container.read(locationProvider.future);

      await container.read(locationProvider.notifier).fetchLocation();
      await container.read(locationProvider.notifier).fetchLocation();

      final state = container.read(locationProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isNotNull);
    });
  });
}
