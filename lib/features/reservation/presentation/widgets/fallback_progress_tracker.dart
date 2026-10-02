import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../domain/models/hold_status.dart';

/// Panel visualizing automatic sequential fallback standby status during the 2-minute hold window.
class FallbackProgressTracker extends StatelessWidget {
  const FallbackProgressTracker({
    required this.currentHospital,
    required this.fallbackHospital,
    required this.status,
    required this.onAdvanceToFallback,
    super.key,
  });

  final HospitalMatch currentHospital;
  final HospitalMatch? fallbackHospital;
  final HoldLifecycleState status;
  final VoidCallback onAdvanceToFallback;

  @override
  Widget build(BuildContext context) {
    // If hold is already locked & confirmed, fallback is disengaged
    if (status.isAccepted) {
      return BedLinkCard(
        variant: BedLinkCardVariant.muted,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.secondaryTeal,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Safety fallback disengaged: ${currentHospital.name} confirmed.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final hasFallback = fallbackHospital != null;
    final isFailed = status.isRejected || status.isTimedOut;

    return BedLinkCard(
      variant: isFailed ? BedLinkCardVariant.critical : BedLinkCardVariant.defaultCard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      size: 14,
                      color: isFailed ? AppColors.criticalRed : AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'AUTOMATED SAFETY FALLBACK',
                        style: AppTypography.operationalLabel.copyWith(
                          color: isFailed ? AppColors.criticalRed : AppColors.secondaryTeal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BedLinkBadge(
                label: hasFallback ? 'STANDBY ACTIVE' : 'NO STANDBY',
                backgroundColor: hasFallback ? AppColors.tealSurface : AppColors.surfaceSubtle,
                textColor: hasFallback ? AppColors.tealDark : AppColors.textMuted,
                borderColor: hasFallback ? AppColors.tealBorder : AppColors.border,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fallback Details or No Standby State
          if (hasFallback) ...[
            Text(
              isFailed
                  ? '${currentHospital.name} could not secure bed. Advancing to standby:'
                  : 'If ${currentHospital.name} does not confirm before timeout, BedLink automatically routes to:',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isFailed ? AppColors.criticalBorder : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${fallbackHospital!.rank}',
                              style: AppTypography.operationalDataBold.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fallbackHospital!.name,
                                style: AppTypography.cardTitle.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fallbackHospital!.area} • ${fallbackHospital!.distanceDisplayText}',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BedLinkBadge(
                    label: '${fallbackHospital!.etaMinutes} MIN',
                    backgroundColor: AppColors.tealSurface,
                    textColor: AppColors.tealDark,
                    borderColor: AppColors.tealBorder,
                    icon: Icons.access_time_rounded,
                    isMonospaced: true,
                  ),
                ],
              ),
            ),
            if (isFailed) ...[
              const SizedBox(height: 10),
              BedLinkButton(
                label: 'OFFER TO ${fallbackHospital!.name.toUpperCase()}',
                icon: Icons.forward_to_inbox_rounded,
                variant: BedLinkButtonVariant.available,
                onPressed: onAdvanceToFallback,
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No additional candidate hospitals match current clinical requirements within radius.',
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
