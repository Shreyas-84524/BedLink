import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';

/// High-visibility data freshness badge adhering to PRD semantic tokens.
class FreshnessBadge extends StatelessWidget {
  const FreshnessBadge({
    required this.freshnessState,
    this.minutesAgo,
    super.key,
  });

  final FreshnessState freshnessState;
  final int? minutesAgo;

  @override
  Widget build(BuildContext context) {
    final colors = freshnessState.colors;
    final labelText = minutesAgo != null
        ? (minutesAgo! <= 1
            ? 'JUST NOW'
            : 'UPDATED ${minutesAgo}M AGO')
        : freshnessState.label.toUpperCase();

    return BedLinkBadge(
      label: labelText,
      backgroundColor: colors.background,
      textColor: colors.text,
      borderColor: colors.border,
      icon: Icons.access_time_filled_rounded,
      isMonospaced: true,
    );
  }
}

/// Capacity / Department emergency load indicator chip.
class HospitalLoadBadge extends StatelessWidget {
  const HospitalLoadBadge({
    required this.loadState,
    this.occupancyRate,
    super.key,
  });

  final HospitalLoadState loadState;
  final int? occupancyRate;

  @override
  Widget build(BuildContext context) {
    final colors = loadState.colors;
    final labelText = occupancyRate != null
        ? '$occupancyRate% OCCUPIED'
        : loadState.label.toUpperCase();

    return BedLinkBadge(
      label: labelText,
      backgroundColor: colors.background,
      textColor: colors.text,
      borderColor: colors.border,
      icon: Icons.local_hospital_rounded,
      isMonospaced: true,
    );
  }
}

/// Recommendation tier badge for ranked candidate hospitals.
class RecommendationTierBadge extends StatelessWidget {
  const RecommendationTierBadge({
    required this.tierLabel,
    this.isTopMatch = false,
    this.isDivertRisk = false,
    super.key,
  });

  final String tierLabel;
  final bool isTopMatch;
  final bool isDivertRisk;

  @override
  Widget build(BuildContext context) {
    if (isTopMatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.tealSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.secondaryTeal, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star_rounded,
              size: 13,
              color: AppColors.secondaryTeal,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                tierLabel,
                style: AppTypography.operationalDataBold.copyWith(
                  color: AppColors.tealDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (isDivertRisk) {
      return BedLinkBadge(
        label: tierLabel,
        backgroundColor: AppColors.criticalSurface,
        textColor: AppColors.criticalDark,
        borderColor: AppColors.criticalBorder,
        icon: Icons.warning_amber_rounded,
        isMonospaced: true,
      );
    }

    return BedLinkBadge(
      label: tierLabel,
      backgroundColor: AppColors.surfaceSubtle,
      textColor: AppColors.textPrimary,
      borderColor: AppColors.border,
      icon: Icons.check_circle_outline_rounded,
      isMonospaced: true,
    );
  }
}
