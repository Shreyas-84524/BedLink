import 'package:bedlink/core/theme/app_colors.dart';
import 'package:bedlink/core/theme/app_theme.dart';
import 'package:bedlink/core/theme/app_typography.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Design Tokens & Semantic State Tests', () {
    test('AppColors core tokens are distinct and valid', () {
      expect(AppColors.primarySlate.toARGB32(), 0xFF0F172A);
      expect(AppColors.secondaryTeal.toARGB32(), 0xFF0D9488);
      expect(AppColors.criticalRed.toARGB32(), 0xFFDC2626);
      expect(AppColors.warningAmber.toARGB32(), 0xFFF59E0B);
      expect(AppColors.background.toARGB32(), 0xFFF8FAFC);
    });

    test('FreshnessState categorizes minutes correctly', () {
      expect(FreshnessState.fromMinutes(2), FreshnessState.fresh);
      expect(FreshnessState.fromMinutes(4), FreshnessState.fresh);
      expect(FreshnessState.fromMinutes(5), FreshnessState.recent);
      expect(FreshnessState.fromMinutes(14), FreshnessState.recent);
      expect(FreshnessState.fromMinutes(15), FreshnessState.aging);
      expect(FreshnessState.fromMinutes(29), FreshnessState.aging);
      expect(FreshnessState.fromMinutes(30), FreshnessState.stale);
      expect(FreshnessState.fromMinutes(60), FreshnessState.stale);
    });

    test('HospitalLoadState categorizes occupancy percentages', () {
      expect(HospitalLoadState.fromOccupancy(null), HospitalLoadState.unknown);
      expect(HospitalLoadState.fromOccupancy(0.50), HospitalLoadState.low);
      expect(HospitalLoadState.fromOccupancy(0.80), HospitalLoadState.moderate);
      expect(HospitalLoadState.fromOccupancy(0.95), HospitalLoadState.high);
    });

    test('AvailabilityState categorizes bed counts correctly', () {
      expect(AvailabilityState.fromCount(0), AvailabilityState.unavailable);
      expect(AvailabilityState.fromCount(1), AvailabilityState.limited);
      expect(AvailabilityState.fromCount(2), AvailabilityState.limited);
      expect(AvailabilityState.fromCount(3), AvailabilityState.available);
      expect(AvailabilityState.fromCount(10), AvailabilityState.available);
    });

    test('AppTheme lightTheme configures colorScheme and cards', () {
      final theme = AppTheme.lightTheme;
      expect(theme.colorScheme.primary, AppColors.primarySlate);
      expect(theme.colorScheme.secondary, AppColors.secondaryTeal);
      expect(theme.colorScheme.error, AppColors.criticalRed);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('AppTypography defines valid font sizes and weights', () {
      expect(AppTypography.display.fontSize, 28);
      expect(AppTypography.screenTitle.fontSize, 22);
      expect(AppTypography.cardTitle.fontSize, 16);
      expect(AppTypography.operationalValueLg.fontSize, 28);
      expect(AppTypography.operationalLabel.fontSize, 11);
    });
  });
}
