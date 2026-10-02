import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/hospital_request_item.dart';
import '../providers/hospital_state_provider.dart';

/// Card rendering an incoming emergency reservation offer with a 2-minute response timer,
/// patient acuity, required resources, and Accept / Decline actions.
class HospitalRequestCard extends ConsumerWidget {
  const HospitalRequestCard({
    required this.request,
    super.key,
  });

  final HospitalIncomingRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = request.status;

    return BedLinkCard(
      variant: status.isPending
          ? BedLinkCardVariant.critical
          : status.isAccepted
              ? BedLinkCardVariant.recommended
              : BedLinkCardVariant.muted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Urgency + Countdown Timer / Status Banner
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
                      label: request.urgency.label,
                      backgroundColor: request.urgency.backgroundColor,
                      textColor: request.urgency.color,
                      borderColor: request.urgency.borderColor,
                      icon: Icons.warning_amber_rounded,
                    ),
                    Text(
                      request.ambulanceId,
                      style: AppTypography.operationalLabel.copyWith(
                        color: AppColors.primarySlate,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              _buildStatusPill(request),
            ],
          ),
          const SizedBox(height: 12),

          // Patient Name & Demographics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.patientDisplayName,
                  style: AppTypography.cardTitle.copyWith(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${request.patientAge} YRS • ${request.biologicalSex}',
                style: AppTypography.operationalLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Chief Complaint
          Text(
            request.chiefComplaint,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Inbound ETA & Triage Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.airport_shuttle_outlined, size: 16, color: AppColors.infoBlue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'ESTIMATED ARRIVAL (ETA):',
                          style: AppTypography.operationalLabel.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${request.etaMinutes} MINS',
                  style: AppTypography.operationalValueSm.copyWith(
                    color: AppColors.infoBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Required Clinical Beds & Capabilities
          Text(
            'REQUIRED CLINICAL RESOURCES:',
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
              ...request.requiredResources.entries.map((e) {
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
                      const Icon(Icons.hotel_outlined, size: 14, color: AppColors.primarySlate),
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
              ...request.requiredCapabilities.map((c) {
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.secondaryTeal),
                      const SizedBox(width: 4),
                      Text(
                        capLabel,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryTeal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons or Resolved State
          if (status.isPending) ...[
            Row(
              children: [
                Expanded(
                  child: BedLinkButton(
                    label: 'DECLINE / DIVERT',
                    icon: Icons.close_rounded,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () => _showDeclineDialog(context, ref),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BedLinkButton(
                    label: 'ACCEPT EMERGENCY',
                    icon: Icons.check_circle_rounded,
                    variant: BedLinkButtonVariant.available,
                    onPressed: () {
                      ref.read(hospitalStateProvider.notifier).acceptRequest(request.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Accepted inbound request ${request.ambulanceId}. Bed held.'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Simulator trigger to test 120s timeout
            Center(
              child: InkWell(
                onTap: () {
                  ref.read(hospitalStateProvider.notifier).expireRequest(request.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'Simulate 120s Expiry Timeout',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ] else if (status.isAccepted) ...[
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
                      'BED RESERVED • Inbound ambulance dispatched to this ER. View details in Active Holds.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.tealDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status.isRejected) ...[
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
                  const Icon(Icons.cancel_outlined, color: AppColors.criticalRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REQUEST DECLINED / DIVERTED',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.criticalRed,
                          ),
                        ),
                        if (request.rejectionReason != null)
                          Text(
                            request.rejectionReason!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status.isExpired) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_off_outlined, color: AppColors.warningAmber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'OFFER TIMED OUT (120s) • Patient candidate routed automatically to next nearest facility.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.warningDark,
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

  Widget _buildStatusPill(HospitalIncomingRequest request) {
    if (request.status.isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.criticalSurface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.criticalBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.criticalRed),
            const SizedBox(width: 4),
            Text(
              request.formattedCountdown,
              style: AppTypography.operationalValueSm.copyWith(
                color: AppColors.criticalRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return BedLinkBadge(
      label: request.status.label,
      backgroundColor: request.status.isAccepted
          ? AppColors.tealSurface
          : request.status.isRejected
              ? AppColors.criticalSurface
              : AppColors.warningSurface,
      textColor: request.status.isAccepted
          ? AppColors.tealDark
          : request.status.isRejected
              ? AppColors.criticalRed
              : AppColors.warningDark,
      borderColor: request.status.isAccepted
          ? AppColors.tealBorder
          : request.status.isRejected
              ? AppColors.criticalBorder
              : AppColors.warningBorder,
    );
  }

  void _showDeclineDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Decline Emergency Offer', style: AppTypography.cardTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select reason for diverting ambulance to the next hospital in the ranking:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 12),
              _buildReasonTile(dialogCtx, ref, 'Emergency Department at maximum surge capacity'),
              _buildReasonTile(dialogCtx, ref, 'Specialist / Cath Lab currently diverted'),
              _buildReasonTile(dialogCtx, ref, 'Equipment sterilization or maintenance'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReasonTile(BuildContext dialogCtx, WidgetRef ref, String reason) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.radio_button_unchecked, size: 18),
      title: Text(reason, style: AppTypography.bodySmall),
      onTap: () {
        ref.read(hospitalStateProvider.notifier).rejectRequest(request.id, reason: reason);
        Navigator.of(dialogCtx).pop();
      },
    );
  }
}
