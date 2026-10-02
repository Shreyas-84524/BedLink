import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';

/// Compact card summarizing inbound patient triage, clinical urgency, and required hospital resources.
class InboundPatientSummaryCard extends ConsumerWidget {
  const InboundPatientSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientIntakeProvider);
    final requirements = ref.watch(bedRequirementProvider);

    final urgencyColor = patient.urgency.color;

    // Collect requested resources from Phase 5 state
    final resourceLabels = <String>[];
    for (final entry in requirements.selectedRequirements.entries) {
      final res = ClinicalResourceCatalogue.findById(entry.key);
      if (res != null) {
        if (res.isCountable) {
          resourceLabels.add('${entry.value}× ${res.shortLabel}');
        } else {
          resourceLabels.add(res.shortLabel);
        }
      }
    }

    return BedLinkCard(
      variant: BedLinkCardVariant.defaultCard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title & Ambulance Unit Tag
          const Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'INBOUND PATIENT SUMMARY',
                style: AppTypography.operationalLabel,
              ),
              BedLinkBadge(
                label: 'AMB-108 • IN-FLIGHT',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                icon: Icons.emergency_rounded,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Patient Name, Urgency Pill, and Age/Sex
          Row(
            children: [
              // Urgency Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: urgencyColor, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: urgencyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      patient.urgency.label.toUpperCase(),
                      style: AppTypography.operationalLabel.copyWith(
                        color: urgencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Patient Name & Demographics
              Expanded(
                child: Text(
                  '${patient.displayName} • ${patient.age}y ${patient.biologicalSex.shortCode}',
                  style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chief Complaint
          Row(
            children: [
              const Icon(
                Icons.medical_information_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  patient.chiefComplaint.isNotEmpty
                      ? patient.chiefComplaint
                      : 'Acute Medical Emergency',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 10),

          // Clinical Requirements Label & Chips
          const Text(
            'MANDATORY HELD RESOURCES',
            style: AppTypography.operationalLabel,
          ),
          const SizedBox(height: 6),
          if (resourceLabels.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: resourceLabels.map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.tealSurface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.tealBorder, width: 1.0),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.operationalDataBold.copyWith(
                      color: AppColors.tealDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(growable: false),
            )
          else
            const Text(
              'No specific resource quantities requested',
              style: AppTypography.caption,
            ),
        ],
      ),
    );
  }
}
