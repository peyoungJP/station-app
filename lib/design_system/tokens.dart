import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFF4299F0);
  static const secondary = Color(0xFFA8E6CF);

  // Semantic (Light)
  static const bgCanvasLight = Color(0xFFF8F9FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textMainLight = Color(0xFF2F3542);
  static const textMutedLight = Color(0xFF6B7280);
  static const textSubtleLight = Color(0xFF9CA3AF);
  static const borderLight = Color(0xFFF3F4F6);

  // Semantic (Dark)
  static const bgCanvasDark = Color(0xFF101922);
  static const surfaceDark = Color(0xFF1E293B);
  static const textMainDark = Color(0xFFF3F4F6);
  static const textMutedDark = Color(0xFF9CA3AF);
  static const textSubtleDark = Color(0xFF9CA3AF);
  static const borderDark = Color(0xFF334155);

  // Alpha
  static final primary10 = primary.withValues(alpha: 0.10);
  static final primary20 = primary.withValues(alpha: 0.20);
  static const shadowBase = Color(0x0D000000);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 8.0;
  static const sm = 16.0;
  static const sm2 = 20.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 40.0;
}

class AppRadius {
  AppRadius._();

  static const xs = 12.0;
  static const card = 16.0;
  static const lg = 32.0;
  static const full = 9999.0;
}

class AppElevation {
  AppElevation._();

  static const shadow1 = [
    BoxShadow(blurRadius: 10, color: AppColors.shadowBase),
  ];
}
