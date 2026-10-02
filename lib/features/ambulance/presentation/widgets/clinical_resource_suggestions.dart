import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/inputs/bedlink_chips.dart';
import '../../domain/models/clinical_resource_catalogue.dart';
import '../providers/intake_provider.dart';
import '../providers/requirement_provider.dart';

/// Contextual auto-suggestions based on chief complaint & frequent clinical assets (Sub-phase 5.3).
class ClinicalResourceSuggestions extends ConsumerWidget {
  const ClinicalResourceSuggestions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaint = ref.watch(patientIntakeProvider.select((p) => p.chiefComplaint));
    final requirementState = ref.watch(bedRequirementProvider);
    final notifier = ref.read(bedRequirementProvider.notifier);

    final suggested = ClinicalResourceCatalogue.suggestForComplaint(complaint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (suggested.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 15, color: AppColors.secondaryTeal),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'SUGGESTED FOR THIS COMPLAINT',
                  style: AppTypography.operationalLabel.copyWith(color: AppColors.tealDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggested.map((resource) {
              final isAdded = requirementState.isSelected(resource.id);
              return BedLinkQuickAddChip(
                label: resource.shortLabel,
                icon: resource.icon,
                isAdded: isAdded,
                onTap: () => notifier.toggleResource(resource.id),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 12),
        ],
        const Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 15, color: AppColors.primarySlate),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'FREQUENT CLINICAL RESOURCES',
                style: AppTypography.operationalLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: ClinicalResourceCatalogue.allResources.take(6).map((resource) {
            final isAdded = requirementState.isSelected(resource.id);
            return BedLinkQuickAddChip(
              label: resource.shortLabel,
              icon: resource.icon,
              isAdded: isAdded,
              onTap: () => notifier.toggleResource(resource.id),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}
