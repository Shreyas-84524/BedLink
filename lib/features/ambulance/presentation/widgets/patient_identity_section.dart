import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_text_field.dart';
import '../providers/intake_provider.dart';

/// Patient Identity entry section supporting direct name input and rapid "Unknown Patient" triage preset.
class PatientIdentitySection extends ConsumerStatefulWidget {
  const PatientIdentitySection({super.key});

  @override
  ConsumerState<PatientIdentitySection> createState() =>
      _PatientIdentitySectionState();
}

class _PatientIdentitySectionState extends ConsumerState<PatientIdentitySection> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(patientIntakeProvider).patientName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intake = ref.watch(patientIntakeProvider);

    // Sync external preset changes to controller text if necessary
    if (!intake.isUnknownPatient &&
        intake.patientName != _nameController.text &&
        !_nameController.value.isComposingRangeValid) {
      _nameController.text = intake.patientName;
    }

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
                  'PATIENT IDENTITY',
                  style: AppTypography.operationalLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (intake.isUnknownPatient) ...[
                const SizedBox(width: 6),
                const BedLinkBadge(
                  label: 'UNKNOWN / UNCONSCIOUS',
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          BedLinkTextField(
            controller: _nameController,
            label: 'PATIENT FULL NAME / TRIAGE TAG #',
            hint: intake.isUnknownPatient
                ? 'Identity Unknown (Auto-Tagged #MUM-TRAUMA)'
                : 'e.g. Ramesh Patil or Triage Tag #104',
            enabled: !intake.isUnknownPatient,
            prefixIcon: Icons.person_outline_rounded,
            onChanged: (val) {
              ref.read(patientIntakeProvider.notifier).setPatientName(val);
            },
          ),
          const SizedBox(height: 10),
          // Quick Unknown / Unconscious Action Chip
          InkWell(
            onTap: () {
              final newUnknownState = !intake.isUnknownPatient;
              ref
                  .read(patientIntakeProvider.notifier)
                  .toggleUnknownPatient(newUnknownState);
              if (newUnknownState) {
                _nameController.clear();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: intake.isUnknownPatient
                    ? AppColors.primarySlate
                    : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: intake.isUnknownPatient
                      ? AppColors.primarySlate
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    intake.isUnknownPatient
                        ? Icons.check_circle_rounded
                        : Icons.help_outline_rounded,
                    size: 16,
                    color: intake.isUnknownPatient
                        ? AppColors.textInverse
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '⚡ Unknown / Unconscious Patient',
                      style: AppTypography.bodySmall.copyWith(
                        color: intake.isUnknownPatient
                            ? AppColors.textInverse
                            : AppColors.textPrimary,
                        fontWeight: intake.isUnknownPatient
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
