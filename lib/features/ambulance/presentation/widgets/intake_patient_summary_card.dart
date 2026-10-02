import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/intake_provider.dart';

/// Condensed summary card of the active patient intake session (Sub-phase 5.1).
class IntakePatientSummaryCard extends ConsumerWidget {
  const IntakePatientSummaryCard({
    this.onEditTap,
    super.key,
  });

  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientIntakeProvider);

    return BedLinkCard(
      variant: BedLinkCardVariant.highlighted,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_rounded, size: 16, color: AppColors.secondaryTeal),
              const SizedBox(width: 6),
              const Flexible(
                child: Text(
                  'ACTIVE PATIENT SUMMARY',
                  style: AppTypography.operationalLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEditTap ?? () => context.go('/ambulance/intake'),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'EDIT',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.secondaryTeal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.secondaryTeal),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.displayName,
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${patient.age} YRS (${patient.ageCohort.toUpperCase()}) • ${patient.biologicalSex.label.toUpperCase()}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: patient.urgency.label,
                backgroundColor: patient.urgency.backgroundColor,
                textColor: patient.urgency.color,
                borderColor: patient.urgency.borderColor,
              ),
            ],
          ),
          if (patient.chiefComplaint.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.primarySlate),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      patient.chiefComplaint,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
