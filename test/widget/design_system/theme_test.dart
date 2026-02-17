import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_first_app/design_system/theme.dart';
import 'package:my_first_app/design_system/tokens.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    HttpOverrides.global = null;
  });

  group('AppTheme', () {
    testWidgets('LightテーマのbrightnessがBrightness.lightである', (tester) async {
      final theme = AppTheme.light;
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('DarkテーマのbrightnessがBrightness.darkである', (tester) async {
      final theme = AppTheme.dark;
      expect(theme.brightness, Brightness.dark);
    });

    testWidgets('LightテーマでMaterial3が有効である', (tester) async {
      final theme = AppTheme.light;
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('DarkテーマでMaterial3が有効である', (tester) async {
      final theme = AppTheme.dark;
      expect(theme.useMaterial3, isTrue);
    });

    testWidgets('CardThemeのradiusがAppRadius.cardである', (tester) async {
      final theme = AppTheme.light;
      final cardShape = theme.cardTheme.shape as RoundedRectangleBorder;
      final radius = cardShape.borderRadius as BorderRadius;
      expect(radius, BorderRadius.circular(AppRadius.card));
    });
  });
}
