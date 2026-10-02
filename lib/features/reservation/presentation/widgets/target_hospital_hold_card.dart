import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/badges/status_badges.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../domain/models/hold_status.dart';

/// Featured card detailing the destination hospital target, transit metrics, and active hold locking status.
class TargetHospitalHoldCard extends StatelessWidget {
  const TargetHospitalHoldCard({
    required this.hospital,
    required this.status,
    required this.requiredResourceLabels,
    this.onCallHospital,
    super.key,
  });

  final HospitalMatch hospital;
  final HoldLifecycleState status;
  final List<String> requiredResourceLabels;
  final VoidCallback? onCallHospital;

  @override
  Widget build(BuildContext context) {
    final isAccepted = status.isAccepted;
    final cardVariant = isAccepted
        ? BedLinkCardVariant.recommended
        : (status.isRejected || status.isTimedOut)
            ? BedLinkCardVariant.warning
            : BedLinkCardVariant.defaultCard;

    return BedLinkCard(
      variant: cardVariant,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Target Header + Hold Status Badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 8),
                  const Text(
                    'TARGET FACILITY',
                    style: AppTypography.operationalLabel,
                  ),
                ],
              ),
              _buildHoldStatusBadge(),
            ],
          ),
          const SizedBox(height: 10),

          // Hospital Name
          Text(
            hospital.name,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 17,
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
          const SizedBox(height: 12),

          // Travel Time & Distance Readout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 16,
                      color: AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${hospital.etaMinutes} MIN • ${hospital.distanceDisplayText}',
                      style: AppTypography.operationalDataBold.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    hospital.routeSummary,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Operational Status Indicators
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              FreshnessBadge(
                state: hospital.freshnessState,
                customLabel: hospital.freshnessDisplayText.toUpperCase(),
              ),
              HospitalLoadBadge(
                state: hospital.loadState,
                customLabel: hospital.occupancyDisplayText.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Resources Requested & Contact Action
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAccepted ? AppColors.tealSurface : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isAccepted ? AppColors.tealBorder : AppColors.borderSubtle,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isAccepted
                            ? 'RESOURCES RESERVED & SECURED'
                            : 'HOLD REQUEST SUBMITTED',
                        style: AppTypography.operationalLabel.copyWith(
                          color: isAccepted ? AppColors.tealDark : AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isAccepted) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.tealDark,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                if (requiredResourceLabels.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: requiredResourceLabels.map((resLabel) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAccepted ? AppColors.surface : AppColors.tealSurface,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: isAccepted ? AppColors.secondaryTeal : AppColors.tealBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          resLabel,
                          style: AppTypography.operationalDataBold.copyWith(
                            color: isAccepted ? AppColors.secondaryTeal : AppColors.tealDark,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(growable: false),
                  ),
                const SizedBox(height: 8),

                // Direct Trauma Desk Phone Call
                InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: onCallHospital,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_in_talk_rounded,
                          size: 14,
                          color: AppColors.secondaryTeal,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Trauma Desk: ${hospital.emergencyPhone}',
                            style: AppTypography.operationalDataBold.copyWith(
                              color: AppColors.secondaryTeal,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldStatusBadge() {
    switch (status) {
      case HoldLifecycleState.accepted:
        return const BedLinkBadge(
          label: 'LOCKED • BED CONFIRMED',
          backgroundColor: AppColors.tealSurface,
          textColor: AppColors.tealDark,
          borderColor: AppColors.secondaryTeal,
          icon: Icons.lock_rounded,
          isMonospaced: true,
        );
      case HoldLifecycleState.rejected:
        return const BedLinkBadge(
          label: 'DECLINED BY DESK',
          backgroundColor: AppColors.criticalSurface,
          textColor: AppColors.criticalDark,
          borderColor: AppColors.criticalBorder,
          icon: Icons.cancel_rounded,
          isMonospaced: true,
        );
      case HoldLifecycleState.timedOut:
        return const BedLinkBadge(
          label: 'HOLD EXPIRED',
          backgroundColor: AppColors.criticalSurface,
          textColor: AppColors.criticalDark,
          borderColor: AppColors.criticalBorder,
          icon: Icons.timer_off_rounded,
          isMonospaced: true,
        );
      case HoldLifecycleState.fallbackTransition:
        return const BedLinkBadge(
          label: 'ROUTING FALLBACK...',
          backgroundColor: AppColors.warningSurface,
          textColor: AppColors.warningDark,
          borderColor: AppColors.warningBorder,
          icon: Icons.alt_route_rounded,
          isMonospaced: true,
        );
      case HoldLifecycleState.pending:
        return const BedLinkBadge(
          label: 'HOLD PENDING (120S)',
          backgroundColor: AppColors.warningSurface,
          textColor: AppColors.warningDark,
          borderColor: AppColors.warningBorder,
          icon: Icons.hourglass_top_rounded,
          isMonospaced: true,
        );
    }
  }
}
