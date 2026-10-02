import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_counter_control.dart';
import '../providers/intake_provider.dart';

/// Patient Age selection section with rapid +/- counter and dynamic demographic cohort indication.
class PatientAgeSelector extends ConsumerWidget {
  const PatientAgeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intake = ref.watch(patientIntakeProvider);

    return BedLinkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PATIENT AGE',
                style: AppTypography.operationalLabel,
              ),
              BedLinkBadge(
                label: intake.ageCohort.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BedLinkCounterControl(
            value: intake.age,
            min: 0,
            max: 125,
            unit: 'YEARS OLD',
            onChanged: (newAge) {
              ref.read(patientIntakeProvider.notifier).setAge(newAge);
            },
          ),
          const SizedBox(height: 12),
          // Fast Age Preset Chips for ambulance crew
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPresetChip(
                context: context,
                ref: ref,
                label: '👶 Infant (6mo)',
                age: 0,
                isSelected: intake.age == 0,
              ),
              _buildPresetChip(
                context: context,
                ref: ref,
                label: '🧒 Child (8y)',
                age: 8,
                isSelected: intake.age == 8,
              ),
              _buildPresetChip(
                context: context,
                ref: ref,
                label: '🧑 Adult (45y)',
                age: 45,
                isSelected: intake.age == 45,
              ),
              _buildPresetChip(
                context: context,
                ref: ref,
                label: '👴 Senior (72y)',
                age: 72,
                isSelected: intake.age == 72,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required int age,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(patientIntakeProvider.notifier).setAge(age);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySlate : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.primarySlate : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.textInverse : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
