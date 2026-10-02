import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/hospital_match.dart';
import 'freshness_tag.dart';
import 'mock_route_preview.dart';

/// Featured card for the #1 ranked primary hospital candidate.
class PrimaryHospitalCard extends StatelessWidget {
  const PrimaryHospitalCard({
    required this.hospital,
    required this.onRequestHold,
    this.requestedBedType,
    super.key,
  });

  final HospitalMatch hospital;
  final VoidCallback onRequestHold;
  final String? requestedBedType;

  @override
  Widget build(BuildContext context) {
    final icuCount = hospital.getAvailableCount('icu_bed');
    final ventCount = hospital.getAvailableCount('ventilator');
    final emergCount = hospital.getAvailableCount('emergency_bed');

    return BedLinkCard(
      variant: BedLinkCardVariant.recommended,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Rank #1 Banner & Match Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: RecommendationTierBadge(
                  tierLabel: '#1 TOP RECOMMENDATION',
                  isTopMatch: true,
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: '${hospital.matchScore.toStringAsFixed(1)} SCORE',
                backgroundColor: AppColors.tealSurface,
                textColor: AppColors.tealDark,
                borderColor: AppColors.tealBorder,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Hospital Identity & Area
          Text(
            hospital.name,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${hospital.area} • ${hospital.address}',
                  style: AppTypography.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Big Metric Strip: Road Travel Time & Distance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Travel Time
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'EST. ROAD TRANSIT',
                        style: AppTypography.operationalLabel,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${hospital.etaMinutes}',
                            style: AppTypography.operationalValueLg.copyWith(
                              color: AppColors.secondaryTeal,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'MIN',
                            style: AppTypography.operationalLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border,
                ),
                // Distance
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'ROAD DISTANCE',
                        style: AppTypography.operationalLabel,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            hospital.distanceKm.toStringAsFixed(1),
                            style: AppTypography.operationalValueLg.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'KM',
                            style: AppTypography.operationalLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Operational Status Badges (Freshness + Load)
          Wrap(
            spacing: 6,
            runSpacing: 6,
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
          const SizedBox(height: 14),

          // Resource Availability Grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MATCHING RESOURCE AVAILABILITY',
                  style: AppTypography.operationalLabel,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ResourceCountPill(
                      label: 'ICU Beds',
                      count: icuCount,
                      isHighlighted: true,
                    ),
                    const SizedBox(width: 6),
                    _ResourceCountPill(
                      label: 'Ventilators',
                      count: ventCount,
                      isHighlighted: true,
                    ),
                    const SizedBox(width: 6),
                    _ResourceCountPill(
                      label: 'ER Beds',
                      count: emergCount,
                      isHighlighted: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Care Capabilities
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: hospital.supportedCapabilities.map((String cap) {
              final formatted = cap.replaceAll('_', ' ').toUpperCase();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  formatted,
                  style: AppTypography.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 14),

          // Vector Route Preview
          MockRoutePreview(
            hospital: hospital,
            compact: true,
          ),
          const SizedBox(height: 16),

          // Primary Hold CTA
          BedLinkButton(
            label: 'REQUEST 2-MIN BED HOLD',
            icon: Icons.timer_outlined,
            variant: BedLinkButtonVariant.available,
            onPressed: onRequestHold,
          ),
        ],
      ),
    );
  }
}

class _ResourceCountPill extends StatelessWidget {
  const _ResourceCountPill({
    required this.label,
    required this.count,
    required this.isHighlighted,
  });

  final String label;
  final int count;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final hasCapacity = count > 0;
    final color = hasCapacity
        ? (isHighlighted ? AppColors.secondaryTeal : AppColors.textPrimary)
        : AppColors.criticalRed;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: hasCapacity ? AppColors.border : AppColors.criticalBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTypography.operationalValue.copyWith(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
