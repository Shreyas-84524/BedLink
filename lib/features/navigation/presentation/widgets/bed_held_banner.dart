import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../../reservation/domain/models/hold_status.dart';
import '../../../reservation/presentation/providers/hold_timer_provider.dart';

/// High-visibility banner displaying the active bed hold guarantee and emergency resource lock.
/// Includes safe recovery states if the hold reservation has lapsed or was unconfirmed.
class BedHeldBanner extends ConsumerWidget {
  const BedHeldBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdState = ref.watch(holdTimerProvider);
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final reqState = ref.watch(bedRequirementProvider);

    final isHoldActive = holdState?.status == HoldLifecycleState.accepted;

    // Recovery Warning Banner if hold is unconfirmed or expired
    if (!isHoldActive) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warningBorder, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warningDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'HOLD RESERVATION UNCONFIRMED',
                    style: AppTypography.operationalLabel.copyWith(
                      color: AppColors.warningDark,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const BedLinkBadge(
                  label: 'ATTENTION',
                  backgroundColor: AppColors.warningSurface,
                  textColor: AppColors.warningDark,
                  borderColor: AppColors.warningBorder,
                  icon: Icons.shield_outlined,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'A locked hospital hold was not recorded for ${selectedHospital?.name ?? "this facility"}. You are proceeding without a secured bed guarantee.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warningDark,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: BedLinkButton(
                    label: 'REVIEW HOLD',
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () => context.go('/ambulance/hold'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BedLinkButton(
                    label: 'FIND FACILITY',
                    variant: BedLinkButtonVariant.primary,
                    onPressed: () => context.go('/ambulance/hospitals'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // High-Visibility Active Bed Hold Banner
    final holdId = holdState?.offerId ?? 'HLD-2026-ACTIVE';
    final hospitalName = selectedHospital?.name ?? 'Emergency Center';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.tealSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.tealBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_rounded,
                color: AppColors.tealDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'BED HOLD ACTIVE • RESOURCE LOCKED',
                  style: AppTypography.operationalLabel.copyWith(
                    color: AppColors.tealDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              BedLinkBadge(
                label: holdId,
                backgroundColor: AppColors.surface,
                textColor: AppColors.tealDark,
                borderColor: AppColors.tealBorder,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$hospitalName confirmed receiving readiness for this transit.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.tealDark,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          // Locked resource tags
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _buildResourceSummaryTags(reqState.selectedRequirements),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tealDark,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  size: 14,
                  color: AppColors.textInverse,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'FACILITY LOCKED • DO NOT DIVERT WITHOUT CLINICAL REASSESSMENT',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textInverse,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildResourceSummaryTags(Map<String, int> requirements) {
    if (requirements.isEmpty) {
      return [
        _buildTag('1× Emergency Bay (General)'),
      ];
    }
    return requirements.entries.map((entry) {
      final res = ClinicalResourceCatalogue.findById(entry.key);
      final label = res != null
          ? (res.isCountable ? '${entry.value}× ${res.shortLabel}' : res.shortLabel)
          : '${entry.value}× ${entry.key}';
      return _buildTag(label);
    }).toList();
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.tealBorder),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: AppColors.tealDark,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
