import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/widgets/station_card.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_app.dart';

void main() {
  group('StationCard', () {
    testWidgets('駅名が表示される', (tester) async {
      // Arrange
      final station = TestFixtures.station(name: '渋谷');
      final widget = buildTestApp(
        Scaffold(
          body: StationCard(station: station, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('渋谷'), findsOneWidget);
    });

    testWidgets('路線名が表示される', (tester) async {
      // Arrange
      final station = TestFixtures.station(lineName: '山手線');
      final widget = buildTestApp(
        Scaffold(
          body: StationCard(station: station, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('山手線'), findsOneWidget);
    });

    testWidgets('distanceがある場合にバッジが表示される', (tester) async {
      // Arrange
      final station = TestFixtures.station(distance: 250);
      final widget = buildTestApp(
        Scaffold(
          body: StationCard(station: station, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('250m'), findsOneWidget);
    });

    testWidgets('distanceがnullの場合にバッジが非表示', (tester) async {
      // Arrange
      final station = TestFixtures.station(distance: null);
      final widget = buildTestApp(
        Scaffold(
          body: StationCard(station: station, onTap: () {}),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      // distance badge text should not exist
      expect(find.textContaining(RegExp(r'\d+m')), findsNothing);
    });

    testWidgets('タップ時にonTapコールバックが呼ばれる', (tester) async {
      // Arrange
      var tapped = false;
      final station = TestFixtures.station();
      final widget = buildTestApp(
        Scaffold(
          body: StationCard(
            station: station,
            onTap: () => tapped = true,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);
      await tester.tap(find.byType(StationCard));

      // Assert
      expect(tapped, isTrue);
    });
  });
}
