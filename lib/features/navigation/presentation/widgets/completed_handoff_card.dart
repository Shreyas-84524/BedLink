import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../providers/navigation_state_provider.dart';

/// Card rendered when patient handoff to the receiving hospital is finalized.
/// Summarizes the full emergency mission and provides single-tap workflow reset.
class CompletedHandoffCard extends ConsumerWidget {
  const CompletedHandoffCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationStateProvider);
    final patient = ref.watch(patientIntakeProvider);
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final reqState = ref.watch(bedRequirementProvider);
    final navNotifier = ref.read(navigationStateProvider.notifier);

    if (!navState.status.isCompleted) {
      return const SizedBox.shrink();
    }

    return BedLinkCard(
      variant: BedLinkCardVariant.highlighted,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Success Icon & Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.tealSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.tealBorder),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PATIENT HANDOFF FINALIZED',
                      style: AppTypography.cardTitle.copyWith(
                        color: AppColors.tealDark,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Care responsibility transferred to ER team',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const BedLinkBadge(
                label: 'RESOLVED',
                backgroundColor: AppColors.tealSurface,
                textColor: AppColors.tealDark,
                borderColor: AppColors.tealBorder,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mission Summary Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MISSION LOG SUMMARY',
                  style: AppTypography.operationalLabel.copyWith(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  label: 'PATIENT',
                  value: '${patient.displayName} (${patient.age} y/o, ${patient.biologicalSex.label})',
                ),
                const SizedBox(height: 6),
                _buildSummaryRow(
                  label: 'RECEIVING FACILITY',
                  value: selectedHospital?.name ?? 'Emergency Center Mumbai',
                ),
                const SizedBox(height: 6),
                _buildSummaryRow(
                  label: 'RESOURCES SECURED',
                  value: _formatResourceList(reqState.selectedRequirements),
                ),
                const SizedBox(height: 6),
                _buildSummaryRow(
                  label: 'STATUS',
                  value: 'Bed Occupied • Transfer Logged to City Census',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Primary Reset Action: Start New Emergency
          BedLinkButton(
            label: 'START NEW EMERGENCY',
            icon: Icons.add_circle_outline_rounded,
            variant: BedLinkButtonVariant.primary,
            onPressed: () {
              navNotifier.resetWorkflow();
              context.go('/ambulance/intake');
            },
          ),
          const SizedBox(height: 10),

          // Secondary Action: Return to Dispatch Home
          BedLinkButton(
            label: 'RETURN TO DISPATCH HOME',
            icon: Icons.home_rounded,
            variant: BedLinkButtonVariant.secondary,
            onPressed: () {
              context.go('/ambulance');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.caption.copyWith(
              color: AppColors.primarySlate,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  String _formatResourceList(Map<String, int> requirements) {
    if (requirements.isEmpty) {
      return '1× General Emergency Bay';
    }
    return requirements.entries.map((entry) {
      final res = ClinicalResourceCatalogue.findById(entry.key);
      if (res != null) {
        return res.isCountable ? '${entry.value}× ${res.shortLabel}' : res.shortLabel;
      }
      return '${entry.value}× ${entry.key}';
    }).join(', ');
  }
}
