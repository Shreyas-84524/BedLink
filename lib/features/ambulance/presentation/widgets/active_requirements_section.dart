import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_chips.dart';
import '../../../../shared/widgets/inputs/bedlink_counter_control.dart';
import '../../domain/models/clinical_resource_catalogue.dart';
import '../providers/requirement_provider.dart';

/// Active clinical requirements display with quantity controls and validation warning (Sub-phase 5.4).
class ActiveRequirementsSection extends ConsumerWidget {
  const ActiveRequirementsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bedRequirementProvider);
    final notifier = ref.read(bedRequirementProvider.notifier);

    final entries = state.selectedRequirements.entries.toList();
    final countableEntries = entries.where((e) {
      final res = ClinicalResourceCatalogue.findById(e.key);
      return res != null && res.isCountable;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.secondaryTeal),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'ACTIVE REQUIREMENTS',
                style: AppTypography.operationalLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.selectedCount > 0) ...[
              const SizedBox(width: 6),
              BedLinkBadge(
                label: '${state.selectedCount}',
                backgroundColor: state.isValid ? AppColors.tealSurface : AppColors.warningSurface,
                textColor: state.isValid ? AppColors.tealDark : AppColors.warningDark,
                borderColor: state.isValid ? AppColors.secondaryTeal : AppColors.warningAmber,
              ),
              const Spacer(),
              InkWell(
                onTap: notifier.clearAll,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'CLEAR',
                    style: AppTypography.operationalLabel.copyWith(
                      color: AppColors.criticalRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: const Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 28, color: AppColors.textMuted),
                SizedBox(height: 6),
                Text(
                  'No Clinical Resources Selected',
                  style: AppTypography.labelStrong,
                ),
                SizedBox(height: 2),
                Text(
                  'Select an emergency preset or add countable beds/equipment below.',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entries.map((entry) {
              final resource = ClinicalResourceCatalogue.findById(entry.key);
              if (resource == null) return const SizedBox.shrink();

              return BedLinkRequirementChip(
                label: resource.shortLabel,
                isCountable: resource.isCountable,
                quantity: entry.value,
                onRemove: () => notifier.removeResource(resource.id),
              );
            }).toList(growable: false),
          ),
          if (countableEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            BedLinkCard(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ADJUST QUANTITIES', style: AppTypography.operationalLabel),
                  const SizedBox(height: 6),
                  ...countableEntries.map((e) {
                    final res = ClinicalResourceCatalogue.findById(e.key)!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(res.icon, size: 16, color: AppColors.secondaryTeal),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              res.name,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: BedLinkCounterControl(
                              value: e.value,
                              min: 1,
                              max: 5,
                              onChanged: (newQty) => notifier.updateQuantity(res.id, newQty),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          if (!state.isValid) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warningAmber, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warningDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hard Filter Rule: At least one countable bed or equipment (e.g. ICU Bed, Emergency Bed) is required.',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
