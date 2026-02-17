import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_first_app/providers/location_provider.dart';
import 'package:my_first_app/providers/station_provider.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/mock_services.dart';

void main() {
  group('NearbyStationsNotifier', () {
    late ProviderContainer container;
    late MockStationService mockStationService;
    late MockLocationService mockLocationService;

    setUp(() {
      mockStationService = MockStationService();
      mockLocationService = MockLocationService();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer({AsyncValue<Position?>? locationState}) {
      return ProviderContainer(
        overrides: [
          stationServiceProvider.overrideWithValue(mockStationService),
          locationServiceProvider.overrideWithValue(mockLocationService),
          if (locationState != null)
            locationProvider.overrideWith(() => _FakeLocationNotifier(locationState)),
        ],
      );
    }

    test('初期状態はAsyncData(空リスト)である', () async {
      container = createContainer();
      await container.read(nearbyStationsProvider.future);

      final state = container.read(nearbyStationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isEmpty);
    });

    test('位置情報がnullの場合、fetchしても空リストのまま', () async {
      container = createContainer(
        locationState: const AsyncData(null),
      );
      await container.read(nearbyStationsProvider.future);

      await container.read(nearbyStationsProvider.notifier).fetchNearbyStations();

      final state = container.read(nearbyStationsProvider);
      expect(state.valueOrNull, isEmpty);
    });

    test('位置情報がある場合、fetchで駅リストがAsyncDataに入る', () async {
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

      mockStationService.mockResult = [
        TestFixtures.station(name: '東京'),
        TestFixtures.station(id: 's2', name: '有楽町'),
      ];

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyStationsProvider.future);

      await container.read(nearbyStationsProvider.notifier).fetchNearbyStations();

      final state = container.read(nearbyStationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull!.length, 2);
      expect(state.valueOrNull!.first.name, '東京');
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

      mockStationService.shouldThrow = true;

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyStationsProvider.future);

      await container.read(nearbyStationsProvider.notifier).fetchNearbyStations();

      final state = container.read(nearbyStationsProvider);
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

      mockStationService.mockResult = [];

      container = createContainer(
        locationState: AsyncData(mockPosition),
      );
      await container.read(nearbyStationsProvider.future);

      await container.read(nearbyStationsProvider.notifier).fetchNearbyStations();

      final state = container.read(nearbyStationsProvider);
      expect(state, isA<AsyncData>());
      expect(state.valueOrNull, isEmpty);
    });
  });
}

class _FakeLocationNotifier extends AsyncNotifier<Position?> implements LocationNotifier {
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
