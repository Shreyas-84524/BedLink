import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography system for BedLink.
/// Uses robust sans-serif styling for operational clarity and monospaced tabular metrics for real-time telemetry.
class AppTypography {
  AppTypography._();

  static const String primaryFontFamily = 'Chivo';
  static const String monoFontFamily = 'JetBrains Mono';

  // Screen Headings & Display
  static const TextStyle display = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle screenTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Body Typography
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Labels & UI Annotations
  static const TextStyle label = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelStrong = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    color: AppColors.textInverse,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  // Operational / Data Typography (JetBrains Mono tabular figures)
  static const TextStyle operationalLabel = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.08,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle operationalValueLg = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle operationalValue = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle operationalValueSm = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.textSecondary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle badge = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.06,
    height: 1.2,
  );
}
