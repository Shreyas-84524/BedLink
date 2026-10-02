import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_segmented_selector.dart';
import '../../domain/models/biological_sex.dart';
import '../providers/intake_provider.dart';

/// Biological Sex selection widget adhering to clinical input specifications.
class BiologicalSexSelector extends ConsumerWidget {
  const BiologicalSexSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intake = ref.watch(patientIntakeProvider);

    return BedLinkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BIOLOGICAL SEX',
            style: AppTypography.operationalLabel,
          ),
          const SizedBox(height: 10),
          BedLinkSegmentedSelector<BiologicalSex>(
            options: const [
              BedLinkSegmentOption(
                value: BiologicalSex.male,
                label: 'Male',
                icon: Icons.male_rounded,
              ),
              BedLinkSegmentOption(
                value: BiologicalSex.female,
                label: 'Female',
                icon: Icons.female_rounded,
              ),
              BedLinkSegmentOption(
                value: BiologicalSex.other,
                label: 'Other / Unknown',
                icon: Icons.transgender_rounded,
              ),
            ],
            selectedValue: intake.biologicalSex,
            onChanged: (newSex) {
              ref.read(patientIntakeProvider.notifier).setBiologicalSex(newSex);
            },
          ),
        ],
      ),
    );
  }
}
