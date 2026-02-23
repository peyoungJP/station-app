import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_app/providers/location_provider.dart';
import 'package:my_first_app/providers/nearby_location_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('NearbyLocationsNotifier', () {
    late ProviderContainer container;
    late MockNearbyLocationService mockService;
    late MockLocationService mockLocationService;

    setUp(() {
      mockService = MockNearbyLocationService();
      mockLocationService = MockLocationService();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer({AsyncValue<Position?>? locationState}) {
      return ProviderContainer(
        overrides: [
          nearbyLocationServiceProvider.overrideWithValue(mockService),
          locationServiceProvider.overrideWithValue(mockLocationService),
          if (locationState != null)
            locationProvider
                .overrideWith(() => _FakeLocationNotifier(locationState)),
        ],
      );
    }

    test('初期状態はAsyncData(空リスト)である', () async {
      container = createContainer();
      await container.read(nearbyLocationsProvider.future);

      final state = container.read(nearbyLocationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isEmpty);
    });

    test('位置情報がnullの場合、fetchしても空リストのまま', () async {
      container = createContainer(
        locationState: const AsyncData(null),
      );
      await container.read(nearbyLocationsProvider.future);

      await container
          .read(nearbyLocationsProvider.notifier)
          .fetchNearbyLocations();

      final state = container.read(nearbyLocationsProvider);
      expect(state.valueOrNull, isEmpty);
    });

    test('位置情報がある場合、fetchでLocationリストがAsyncDataに入る', () async {
      final mockPosition = Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      mockService.mockResult = [
        TestFixtures.location(name: 'テスト駅1'),
        TestFixtures.location(id: 'loc-2', name: 'テスト駅2'),
      ];

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyLocationsProvider.future);

      await container
          .read(nearbyLocationsProvider.notifier)
          .fetchNearbyLocations();

      final state = container.read(nearbyLocationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.length, 2);
      expect(state.valueOrNull!.first.name, 'テスト駅1');
    });

    test('サービスが例外を投げた場合、AsyncErrorになる', () async {
      final mockPosition = Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      mockService.shouldThrow = true;

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyLocationsProvider.future);

      await container
          .read(nearbyLocationsProvider.notifier)
          .fetchNearbyLocations();

      final state = container.read(nearbyLocationsProvider);
      expect(state, isA<AsyncError>());
    });

    test('サービスが空リストを返した場合、空リストがAsyncDataに入る', () async {
      final mockPosition = Position(
        latitude: 35.6812,
        longitude: 139.7671,
        timestamp: DateTime(2026, 1, 1),
        accuracy: 10,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      mockService.mockResult = [];

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyLocationsProvider.future);

      await container
          .read(nearbyLocationsProvider.notifier)
          .fetchNearbyLocations();

      final state = container.read(nearbyLocationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isEmpty);
    });
  });
}

class _FakeLocationNotifier extends AsyncNotifier<Position?>
    implements LocationNotifier {
  final AsyncValue<Position?> _initialState;

  _FakeLocationNotifier(this._initialState);

  @override
  Future<Position?> build() async {
    state = _initialState;
    return _initialState.valueOrNull;
  }

  @override
  Future<void> fetchLocation() async {}
}
