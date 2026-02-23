import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/models/location.dart';
import 'package:my_first_app/widgets/location_card.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('LocationCard', () {
    testWidgets('station型の場合、「〜駅」のタイトルが表示される', (tester) async {
      final location = TestFixtures.location(name: '東京');

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.text('東京駅'), findsOneWidget);
    });

    testWidgets('station型の場合、路線名が表示される', (tester) async {
      final location = TestFixtures.location(
        name: '東京',
        lineName: 'JR中央線',
      );

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.text('JR中央線'), findsOneWidget);
    });

    testWidgets('event型の場合、nameそのままのタイトルが表示される', (tester) async {
      final location = TestFixtures.location(
        type: LocationType.event,
        name: '森道市場2026',
        lineName: null,
        prefecture: null,
      );

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.text('森道市場2026'), findsOneWidget);
    });

    testWidgets('event型でstartDate/endDateがある場合、日付範囲が表示される', (tester) async {
      final location = Location(
        id: 'event-1',
        type: LocationType.event,
        name: '森道市場2026',
        latitude: 34.7,
        longitude: 137.4,
        startDate: DateTime(2026, 5, 16),
        endDate: DateTime(2026, 5, 18),
        distance: 300,
      );

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.text('5/16〜5/18'), findsOneWidget);
    });

    testWidgets('distanceが設定されている場合、距離バッジが表示される', (tester) async {
      final location = TestFixtures.location(distance: 120);

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.text('120m'), findsOneWidget);
    });

    testWidgets('distanceがnullの場合、距離バッジが表示されない', (tester) async {
      final location = TestFixtures.location(distance: null);

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.textContaining('m'), findsNothing);
    });

    testWidgets('タップでコールバックが呼ばれる', (tester) async {
      bool tapped = false;
      final location = TestFixtures.location();

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.byType(LocationCard));
      expect(tapped, isTrue);
    });

    testWidgets('station型の場合、電車アイコンが表示される', (tester) async {
      final location = TestFixtures.location(type: LocationType.station);

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.train), findsOneWidget);
    });

    testWidgets('event型の場合、eventアイコンが表示される', (tester) async {
      final location = TestFixtures.location(
        type: LocationType.event,
        lineName: null,
        prefecture: null,
      );

      await tester.pumpWidget(
        buildTestApp(
          LocationCard(location: location, onTap: () {}),
        ),
      );

      expect(find.byIcon(Icons.event), findsOneWidget);
    });
  });
}
