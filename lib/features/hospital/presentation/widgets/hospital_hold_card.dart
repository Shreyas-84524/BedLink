import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/hospital_hold_item.dart';
import '../providers/hospital_state_provider.dart';

/// Card rendering an active hospital bed reservation hold with en-route tracking and release controls.
class HospitalHoldCard extends ConsumerWidget {
  const HospitalHoldCard({
    required this.hold,
    super.key,
  });

  final HospitalActiveHold hold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = hold.status;

    return BedLinkCard(
      variant: status.isInbound
          ? BedLinkCardVariant.highlighted
          : status.isArrived
              ? BedLinkCardVariant.defaultCard
              : BedLinkCardVariant.muted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Hold ID, Status & Urgency
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    BedLinkBadge(
                      label: hold.urgency.label,
                      backgroundColor: hold.urgency.backgroundColor,
                      textColor: hold.urgency.color,
                      borderColor: hold.urgency.borderColor,
                      icon: Icons.warning_amber_rounded,
                    ),
                    Text(
                      hold.holdId,
                      style: AppTypography.operationalLabel.copyWith(
                        color: AppColors.primarySlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BedLinkBadge(
                label: hold.status.label,
                backgroundColor: status.isInbound
                    ? AppColors.warningSurface
                    : status.isArrived
                        ? AppColors.tealSurface
                        : AppColors.surfaceSubtle,
                textColor: status.isInbound
                    ? AppColors.warningDark
                    : status.isArrived
                        ? AppColors.tealDark
                        : AppColors.textMuted,
                borderColor: status.isInbound
                    ? AppColors.warningBorder
                    : status.isArrived
                        ? AppColors.tealBorder
                        : AppColors.border,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inbound Details: Ambulance & Patient
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hold.patientName,
                      style: AppTypography.cardTitle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'CALLSIGN: ${hold.ambulanceId}',
                      style: AppTypography.operationalLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (status.isInbound)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warningSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.warningBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.near_me_outlined, size: 14, color: AppColors.warningAmber),
                      const SizedBox(width: 4),
                      Text(
                        'ETA: ${hold.etaMinutes} MINS',
                        style: AppTypography.operationalValueSm.copyWith(
                          color: AppColors.warningDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Reserved Beds Breakdown
          Text(
            'HELD CLINICAL RESOURCES (RESERVED):',
            style: AppTypography.operationalLabel.copyWith(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...hold.heldResources.entries.map((e) {
                final bedName = e.key == 'icu_bed'
                    ? 'ICU Bed'
                    : e.key == 'ventilator'
                        ? 'Ventilator'
                        : e.key == 'oxygen_bed'
                            ? 'Oxygen Bed'
                            : 'General Bed';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bookmark_added_rounded, size: 14, color: AppColors.warningAmber),
                      const SizedBox(width: 4),
                      Text(
                        '${e.value}x $bedName',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              ...hold.heldCapabilities.map((c) {
                final capLabel = c == 'cardiac_care'
                    ? 'Cath Lab'
                    : c == 'trauma_care'
                        ? 'Trauma Bay'
                        : 'Burns Unit';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.secondaryTeal.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    capLabel,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryTeal,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          if (status.isInbound) ...[
            Row(
              children: [
                Expanded(
                  child: BedLinkButton(
                    label: 'RELEASE HOLD',
                    icon: Icons.cancel_outlined,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () {
                      ref.read(hospitalStateProvider.notifier).releaseHold(hold.holdId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Hold ${hold.holdId} released. Bed returned to available pool.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BedLinkButton(
                    label: 'CONFIRM ARRIVED',
                    icon: Icons.check_circle_outline_rounded,
                    variant: BedLinkButtonVariant.available,
                    onPressed: () {
                      ref.read(hospitalStateProvider.notifier).markHoldArrived(hold.holdId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Patient ${hold.patientName} marked arrived at ER.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ] else if (status.isArrived) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.tealSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.tealBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.secondaryTeal, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PATIENT ARRIVED • Transferred to Emergency Department care team.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.tealDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status.isReleased) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HOLD RELEASED • Reserved bed capacity returned to general inventory.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
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
