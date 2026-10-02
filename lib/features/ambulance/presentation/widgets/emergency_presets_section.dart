import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../domain/models/clinical_resource_catalogue.dart';
import '../providers/requirement_provider.dart';

/// One-tap emergency preset bundle selector for rapid ambulance triage (Sub-phase 5.5).
class EmergencyPresetsSection extends ConsumerWidget {
  const EmergencyPresetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bedRequirementProvider);
    final notifier = ref.read(bedRequirementProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bolt_rounded, size: 16, color: AppColors.secondaryTeal),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'EMERGENCY PRESET BUNDLES',
                style: AppTypography.operationalLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...ClinicalResourceCatalogue.presets.map((preset) {
          final isApplied = preset.requirements.entries.every(
            (entry) => state.getQuantity(entry.key) == entry.value,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: isApplied ? AppColors.tealSurface : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: isApplied ? AppColors.secondaryTeal : AppColors.border,
                  width: isApplied ? 1.5 : 1.0,
                ),
              ),
              child: InkWell(
                onTap: () => notifier.applyPreset(preset.id),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isApplied ? AppColors.tealDark : AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          preset.icon,
                          size: 16,
                          color: isApplied ? AppColors.textInverse : AppColors.secondaryTeal,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              preset.name,
                              style: AppTypography.labelStrong.copyWith(
                                fontSize: 13,
                                color: isApplied ? AppColors.tealDark : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              preset.subtitle,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                color: isApplied ? AppColors.tealDark : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isApplied)
                        const BedLinkBadge(
                          label: 'APPLIED',
                          backgroundColor: AppColors.tealSurface,
                          textColor: AppColors.tealDark,
                          borderColor: AppColors.secondaryTeal,
                          icon: Icons.check_circle_rounded,
                        )
                      else
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 18,
                          color: AppColors.secondaryTeal,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
