import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/inputs/bedlink_chips.dart';
import '../../../../shared/widgets/inputs/bedlink_search_field.dart';
import '../providers/requirement_provider.dart';

/// Instant filter and search section for the BedLink clinical resource catalogue (Sub-phase 5.2).
class ClinicalResourceSearchSection extends ConsumerWidget {
  const ClinicalResourceSearchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bedRequirementProvider);
    final notifier = ref.read(bedRequirementProvider.notifier);

    final isSearching = state.searchQuery.trim().isNotEmpty;
    final results = state.searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.search_rounded, size: 16, color: AppColors.secondaryTeal),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'SEARCH CLINICAL CATALOGUE',
                style: AppTypography.operationalLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        BedLinkSearchField(
          hint: 'Search beds, ventilators, specialties, burns...',
          onChanged: notifier.setSearchQuery,
          onClear: notifier.clearSearch,
        ),
        if (isSearching) ...[
          const SizedBox(height: 8),
          if (results.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No matching clinical resources found in catalogue.',
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: results.map((resource) {
                final isAdded = state.isSelected(resource.id);
                return BedLinkQuickAddChip(
                  label: resource.name,
                  icon: resource.icon,
                  isAdded: isAdded,
                  onTap: () => notifier.toggleResource(resource.id),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ],
    );
  }
}
