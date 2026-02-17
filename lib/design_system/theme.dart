import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color mainColor, Color mutedColor) {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();
    return baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.zenMaruGothic(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: mainColor,
      ),
      headlineMedium: GoogleFonts.zenMaruGothic(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: mainColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.50,
        color: mainColor,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.60,
        color: mainColor,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.40,
        color: mutedColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.30,
        color: mutedColor,
      ),
    );
  }

  static ThemeData get light {
    final textTheme = _buildTextTheme(
      AppColors.textMainLight,
      AppColors.textMutedLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgCanvasLight,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        elevation: 0,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCanvasLight,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.zenMaruGothic(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textMainLight,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final textTheme = _buildTextTheme(
      AppColors.textMainDark,
      AppColors.textMutedDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgCanvasDark,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        elevation: 0,
        color: AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgCanvasDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.zenMaruGothic(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textMainDark,
        ),
      ),
    );
  }
}
