import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/navigation_state_provider.dart';

/// Interactive card managing arrival confirmation and progression to patient handoff.
class ArrivalConfirmationCard extends ConsumerWidget {
  const ArrivalConfirmationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationStateProvider);
    final navNotifier = ref.read(navigationStateProvider.notifier);

    // If workflow has already completed, this widget is hidden (CompletedHandoffCard takes over)
    if (navState.status.isCompleted) {
      return const SizedBox.shrink();
    }

    // State 1: Ambulance has already confirmed arrival
    if (navState.status.isArrived) {
      return BedLinkCard(
        variant: BedLinkCardVariant.highlighted,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondaryTeal,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ARRIVED AT EMERGENCY BAY',
                    style: AppTypography.operationalLabel.copyWith(
                      color: AppColors.tealDark,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const BedLinkBadge(
                  label: 'ON SCENE',
                  backgroundColor: AppColors.tealSurface,
                  textColor: AppColors.tealDark,
                  borderColor: AppColors.tealBorder,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ambulance arrival recorded. ER staff alerted to receive patient at Emergency Trauma Bay.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            BedLinkButton(
              label: 'COMPLETE PATIENT HANDOFF',
              icon: Icons.assignment_turned_in_rounded,
              variant: BedLinkButtonVariant.available,
              onPressed: () => navNotifier.completeHandoff(),
            ),
          ],
        ),
      );
    }

    // State 2: Approaching Bay (<1 min or arriving) - Primary Arrival Confirmation Button is Armed!
    if (navState.status.isArriving) {
      return BedLinkCard(
        variant: BedLinkCardVariant.highlighted,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.near_me_rounded,
                  color: AppColors.warningDark,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'APPROACHING HOSPITAL BAY (< 200M)',
                    style: AppTypography.operationalLabel.copyWith(
                      color: AppColors.warningDark,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const BedLinkBadge(
                  label: 'ACTION REQUIRED',
                  backgroundColor: AppColors.warningSurface,
                  textColor: AppColors.warningDark,
                  borderColor: AppColors.warningBorder,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap below as soon as wheels stop at the emergency ambulance entrance bay.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            BedLinkButton(
              label: 'CONFIRM ARRIVAL AT HOSPITAL',
              icon: Icons.check_circle_outline_rounded,
              variant: BedLinkButtonVariant.available,
              onPressed: () => navNotifier.confirmArrival(),
            ),
          ],
        ),
      );
    }

    // State 3: En route (still traveling, arrival confirmation armed for when near)
    return BedLinkCard(
      variant: BedLinkCardVariant.defaultCard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.radar_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ARRIVAL PROTOCOL ARMED',
                  style: AppTypography.operationalLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const BedLinkBadge(
                label: 'AUTO-DETECT',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Arrival confirmation activates automatically when approaching within 500m of the emergency entrance.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          // Demo / Simulation shortcut for fast evaluation
          Row(
            children: [
              Expanded(
                child: BedLinkButton(
                  label: 'ADVANCE ROUTE STEP',
                  icon: Icons.fast_forward_rounded,
                  variant: BedLinkButtonVariant.secondary,
                  onPressed: () => navNotifier.advanceProgress(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BedLinkButton(
                  label: 'SIMULATE AT ER BAY',
                  icon: Icons.local_hospital_rounded,
                  variant: BedLinkButtonVariant.compact,
                  onPressed: () => navNotifier.simulateNearArrival(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
