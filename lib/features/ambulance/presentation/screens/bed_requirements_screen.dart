import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../providers/requirement_provider.dart';
import '../widgets/active_requirements_section.dart';
import '../widgets/clinical_resource_search_section.dart';
import '../widgets/clinical_resource_suggestions.dart';
import '../widgets/emergency_presets_section.dart';
import '../widgets/intake_patient_summary_card.dart';

/// Clinical Bed Need Assessment Screen for Ambulance Dispatch (Phase 5).
class BedRequirementsScreen extends ConsumerWidget {
  const BedRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requirementState = ref.watch(bedRequirementProvider);

    return AppScaffold(
      title: 'BED REQUIREMENTS',
      subtitle: 'Step 2 of 5 • Bed Need Assessment',
      child: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 5.1 Patient Summary Banner
                  IntakePatientSummaryCard(),
                  SizedBox(height: 14),

                  // 5.5 Frequent Requirement Shortcuts / Emergency Preset Bundles
                  EmergencyPresetsSection(),
                  SizedBox(height: 14),

                  // 5.3 Auto-Suggest Clinical Resources & Quick Adds
                  ClinicalResourceSuggestions(),
                  SizedBox(height: 14),

                  // 5.2 Clinical Resource Search
                  ClinicalResourceSearchSection(),
                  SizedBox(height: 14),

                  // 5.4 Active Requirement Chips & Quantity Controls
                  ActiveRequirementsSection(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Bottom Action Bar with Navigation & Hard Filter Validation Guard
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!requirementState.isValid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Select at least one countable bed to discover hospitals',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.criticalRed,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                BedLinkButton(
                  label: 'DISCOVER MATCHING HOSPITALS',
                  icon: Icons.hub_outlined,
                  variant: BedLinkButtonVariant.primary,
                  onPressed: requirementState.isValid
                      ? () => context.go('/ambulance/hospitals')
                      : null,
                ),
                const SizedBox(height: 8),
                BedLinkButton(
                  label: 'BACK TO PATIENT INTAKE',
                  icon: Icons.arrow_back_rounded,
                  variant: BedLinkButtonVariant.secondary,
                  onPressed: () => context.go('/ambulance/intake'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
