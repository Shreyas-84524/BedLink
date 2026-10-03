import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../../reservation/domain/models/hold_status.dart';
import '../../../reservation/presentation/providers/hold_timer_provider.dart';
import '../providers/navigation_state_provider.dart';

/// Card rendering the confirmed destination hospital details, live ETA, distance,
/// and secured bed hold breakdown.
class ConfirmedDestinationCard extends ConsumerWidget {
  const ConfirmedDestinationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final holdState = ref.watch(holdTimerProvider);
    final navState = ref.watch(navigationStateProvider);
    final reqState = ref.watch(bedRequirementProvider);

    if (selectedHospital == null) {
      return const SizedBox.shrink();
    }

    final isHoldLocked = holdState?.status == HoldLifecycleState.accepted;

    return BedLinkCard(
      variant: BedLinkCardVariant.highlighted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category label & Status pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'CONFIRMED DESTINATION',
                  style: AppTypography.operationalLabel.copyWith(
                    color: AppColors.primarySlate,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: isHoldLocked ? 'STATUS: LOCKED' : 'STATUS: PENDING',
                backgroundColor: isHoldLocked ? AppColors.tealSurface : AppColors.warningSurface,
                textColor: isHoldLocked ? AppColors.tealDark : AppColors.warningDark,
                borderColor: isHoldLocked ? AppColors.tealBorder : AppColors.warningBorder,
                icon: isHoldLocked ? Icons.lock_rounded : Icons.timer_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Hospital Name & Address
          Text(
            selectedHospital.name,
            style: AppTypography.cardTitle.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            selectedHospital.address,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Telemetry Strip: ETA & Remaining Distance
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16, color: AppColors.secondaryTeal),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMATED ETA',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              navState.formattedEta,
                              style: AppTypography.operationalValueSm.copyWith(
                                color: AppColors.primarySlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.straighten_rounded, size: 16, color: AppColors.infoBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DISTANCE',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              navState.formattedDistance,
                              style: AppTypography.operationalValueSm.copyWith(
                                color: AppColors.primarySlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: AppColors.border),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.local_hospital_outlined, size: 16, color: AppColors.primarySlate),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIER RANK',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '#${selectedHospital.rank}',
                              style: AppTypography.operationalValueSm.copyWith(
                                color: AppColors.primarySlate,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Held Clinical Resources
          Text(
            'HELD FOR PATIENT (RESERVED):',
            style: AppTypography.operationalLabel.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _buildHeldResourceChips(reqState.selectedRequirements),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHeldResourceChips(Map<String, int> requirements) {
    if (requirements.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.tealSurface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.tealBorder),
          ),
          child: Text(
            '1× Emergency Bed (General)',
            style: AppTypography.caption.copyWith(
              color: AppColors.tealDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ];
    }

    return requirements.entries.map((entry) {
      final res = ClinicalResourceCatalogue.findById(entry.key);
      final label = res != null
          ? (res.isCountable ? '${entry.value}× ${res.shortLabel}' : res.shortLabel)
          : '${entry.value}× ${entry.key}';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.tealSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.tealBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_added_rounded, size: 13, color: AppColors.tealDark),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.tealDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
