import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/clinical_urgency.dart';
import '../providers/intake_provider.dart';

/// Clinical Urgency / ESI Acuity selector offering high-salience emergency tier options.
class ClinicalUrgencySelector extends ConsumerWidget {
  const ClinicalUrgencySelector({super.key});

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
              const Flexible(
                child: Text(
                  'CLINICAL URGENCY / ESI TIER',
                  style: AppTypography.operationalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  intake.urgency.label,
                  style: AppTypography.operationalDataBold.copyWith(
                    color: intake.urgency.color,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: ClinicalUrgency.values.map((tier) {
              final isSelected = intake.urgency == tier;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildUrgencyCard(
                  tier: tier,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(patientIntakeProvider.notifier).setUrgency(tier);
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyCard({
    required ClinicalUrgency tier,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData tierIcon;
    switch (tier) {
      case ClinicalUrgency.routine:
        tierIcon = Icons.health_and_safety_outlined;
        break;
      case ClinicalUrgency.urgent:
        tierIcon = Icons.warning_amber_rounded;
        break;
      case ClinicalUrgency.critical:
        tierIcon = Icons.emergency_rounded;
        break;
    }

    return Material(
      color: isSelected ? tier.backgroundColor : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? tier.borderColor : AppColors.border,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio / Selection Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? tier.color : AppColors.borderStrong,
                    width: 2.0,
                  ),
                  color: isSelected ? tier.color : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(tierIcon, size: 16, color: tier.color),
                        const SizedBox(width: 6),
                        Text(
                          tier.label,
                          style: AppTypography.operationalDataBold.copyWith(
                            color: tier.color,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tier.levelTitle,
                            style: AppTypography.label.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
