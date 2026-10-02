import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../providers/matching_provider.dart';

/// Sticky header bar summarizing the active patient triage, mandatory bed requirements, and search radius.
class PatientRequirementSummaryBar extends ConsumerWidget {
  const PatientRequirementSummaryBar({
    this.onEditRequirements,
    super.key,
  });

  final VoidCallback? onEditRequirements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientIntakeProvider);
    final requirements = ref.watch(bedRequirementProvider);
    final matching = ref.watch(matchingProvider);

    final urgencyColor = patient.urgency.color;
    final urgencyText = patient.urgency.label.toUpperCase();

    // Compile list of requested resources
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Patient Triage Tag & Edit Button
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
                      urgencyText,
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

              // Patient Identity info
              Expanded(
                child: Text(
                  patient.displayName,
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Edit Action
              InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: onEditRequirements ?? () => context.go('/ambulance/requirements'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        size: 14,
                        color: AppColors.secondaryTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'EDIT',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.secondaryTeal,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),

          // Row 2: Chief Complaint & Vitals
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  patient.chiefComplaint.isNotEmpty
                      ? patient.chiefComplaint
                      : 'Emergency Assessment',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: '${matching.searchRadiusKm} KM RADIUS',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                isMonospaced: true,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 3: Requested bed/equipment requirement tags
          if (resourceLabels.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: resourceLabels.map((label) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.tealSurface,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.tealBorder, width: 0.8),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.operationalDataBold.copyWith(
                      color: AppColors.tealDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(growable: false),
            )
          else
            const Text(
              'No specific requirements selected (showing general capacity)',
              style: AppTypography.caption,
            ),
        ],
      ),
    );
  }
}
