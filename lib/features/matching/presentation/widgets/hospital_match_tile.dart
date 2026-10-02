import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/hospital_match.dart';
import 'freshness_tag.dart';

/// Reusable secondary ranked hospital card for Ranks #2 through #5.
class HospitalMatchTile extends StatelessWidget {
  const HospitalMatchTile({
    required this.hospital,
    required this.onRequestHold,
    this.isDivertRisk = false,
    this.isIncompatible = false,
    super.key,
  });

  final HospitalMatch hospital;
  final VoidCallback onRequestHold;
  final bool isDivertRisk;
  final bool isIncompatible;

  @override
  Widget build(BuildContext context) {
    final icuCount = hospital.getAvailableCount('icu_bed');
    final ventCount = hospital.getAvailableCount('ventilator');

    BedLinkCardVariant cardVariant = BedLinkCardVariant.defaultCard;
    if (hospital.recommendationTier.isDivertRisk) {
      cardVariant = BedLinkCardVariant.warning;
    } else if (hospital.recommendationTier.isIncompatible) {
      cardVariant = BedLinkCardVariant.muted;
    }

    return BedLinkCard(
      variant: cardVariant,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Rank Badge + Recommendation Tier + Match Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '#${hospital.rank}',
                        style: AppTypography.operationalDataBold.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: RecommendationTierBadge(
                        tierLabel: hospital.recommendationTier.label,
                        isDivertRisk: hospital.recommendationTier.isDivertRisk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BedLinkBadge(
                label: '${hospital.matchScore.toStringAsFixed(1)} SCORE',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Hospital Name and Area
          Text(
            hospital.name,
            style: AppTypography.cardTitle.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            hospital.area,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 10),

          // Row 3: Metrics Grid (ETA, Distance, ICU, Vent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricColumn(
                  label: 'ETA',
                  value: '${hospital.etaMinutes}m',
                  valueColor: AppColors.secondaryTeal,
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                _MetricColumn(
                  label: 'DIST',
                  value: hospital.distanceDisplayText,
                  valueColor: AppColors.textPrimary,
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                _MetricColumn(
                  label: 'ICU',
                  value: '$icuCount',
                  valueColor: icuCount > 0 ? AppColors.textPrimary : AppColors.criticalRed,
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                _MetricColumn(
                  label: 'VENT',
                  value: '$ventCount',
                  valueColor: ventCount > 0 ? AppColors.textPrimary : AppColors.criticalRed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 4: Freshness + Load Tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              FreshnessBadge(
                freshnessState: hospital.freshnessState,
                minutesAgo: hospital.updatedMinutesAgo,
              ),
              HospitalLoadBadge(
                loadState: hospital.loadState,
                occupancyRate: hospital.occupancyRate,
              ),
            ],
          ),

          // Divert Risk / Incompatible Alert Message
          if (hospital.recommendationTier.isDivertRisk) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: AppColors.warningDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'High ER surge (94%). Handoff delays likely.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warningDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (hospital.recommendationTier.isIncompatible) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Stale data (38m) • No matching ICU beds.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Action Button
          BedLinkButton(
            label: hospital.recommendationTier.isIncompatible
                ? 'SPECIALIZED INQUIRY ONLY'
                : 'REQUEST 2-MIN HOLD',
            icon: Icons.timer_outlined,
            variant: hospital.recommendationTier.isDivertRisk
                ? BedLinkButtonVariant.secondary
                : hospital.recommendationTier.isIncompatible
                    ? BedLinkButtonVariant.secondary
                    : BedLinkButtonVariant.available,
            onPressed: onRequestHold,
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.operationalDataBold.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
