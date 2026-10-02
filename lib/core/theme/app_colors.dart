import 'package:flutter/material.dart';

/// Clinical high-contrast design tokens matching design.md and BedLink UI references.
class AppColors {
  AppColors._();

  // Core Authority & Framing
  static const Color primarySlate = Color(0xFF0F172A);
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // High-Availability Medical Teal & Mint (Live states, available assets, positive confirmations)
  static const Color secondaryTeal = Color(0xFF0D9488);
  static const Color tealDark = Color(0xFF115E59);
  static const Color tealSurface = Color(0xFFCCFBF1);
  static const Color tealBorder = Color(0xFF0D9488);
  static const Color mintLive = Color(0xFF86F2E4);

  // Critical Alert Red (Strictly reserved for zero-bed divert, Code Red, critical triage, destructive actions)
  static const Color criticalRed = Color(0xFFDC2626);
  static const Color criticalDark = Color(0xFF991B1B);
  static const Color criticalSurface = Color(0xFFFEE2E2);
  static const Color criticalBorder = Color(0xFFDC2626);

  // Warning & Surge Amber (Bed census >90%, aging data, delayed transfers)
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFF92400E);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color warningBorder = Color(0xFFF59E0B);

  // Info & Neutral Blue (Supporting cards, patient telemetry panels)
  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoDark = Color(0xFF1E40AF);
  static const Color infoSurface = Color(0xFFEFF6FF);
  static const Color infoBorder = Color(0xFFBFDBFE);

  // Neutral Clinical Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color surfaceContainer = Color(0xFFE2E8F0);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Borders & Structural Dividers
  static const Color border = Color(0xFFCBD5E1);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFF94A3B8);
  static const Color borderActive = Color(0xFF0F172A);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textTeal = Color(0xFF115E59);
  static const Color textCritical = Color(0xFF991B1B);
  static const Color textWarning = Color(0xFF92400E);

  // Interactive & State Tokens
  static const Color disabledBackground = Color(0xFFE2E8F0);
  static const Color disabledText = Color(0xFF94A3B8);
  static const Color disabledBorder = Color(0xFFCBD5E1);
}
