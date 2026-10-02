import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/buttons/bedlink_icon_button.dart';
import '../../../../shared/widgets/chrome/bedlink_app_bar.dart';
import '../../../../shared/widgets/inputs/bedlink_validation_message.dart';
import '../providers/intake_provider.dart';
import '../widgets/biological_sex_selector.dart';
import '../widgets/chief_complaint_section.dart';
import '../widgets/clinical_urgency_selector.dart';
import '../widgets/intake_header.dart';
import '../widgets/patient_age_selector.dart';
import '../widgets/patient_identity_section.dart';

/// Full Patient Intake & Clinical Triage Screen (Phase 4 scope).
class PatientIntakeScreen extends ConsumerWidget {
  const PatientIntakeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intake = ref.watch(patientIntakeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BedLinkAppBar(
        title: 'PATIENT INTAKE',
        showLiveBadge: true,
        showBackButton: true,
        actions: [
          BedLinkIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'Reset Intake Form',
            onPressed: () {
              ref.read(patientIntakeProvider.notifier).reset();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Operational Context & Header
            const IntakeHeader(),
            const SizedBox(height: 14),

            // Section 1: Patient Identity
            const PatientIdentitySection(),
            const SizedBox(height: 14),

            // Section 2: Biological Sex
            const BiologicalSexSelector(),
            const SizedBox(height: 14),

            // Section 3: Patient Age
            const PatientAgeSelector(),
            const SizedBox(height: 14),

            // Section 4: Clinical Urgency / ESI
            const ClinicalUrgencySelector(),
            const SizedBox(height: 14),

            // Section 5: Chief Complaint & Notes
            const ChiefComplaintSection(),
            const SizedBox(height: 16),

            // Validation Helper Banner if required fields are missing
            if (!intake.isFormValid) ...[
              BedLinkValidationMessage(
                message: intake.validationErrors.isNotEmpty
                    ? 'REQUIRED: ${intake.validationErrors.first}'
                    : 'Please fill all required patient details.',
                severity: ValidationSeverity.warning,
              ),
              const SizedBox(height: 12),
            ],

            // Primary Workflow Continuation CTA
            BedLinkButton(
              label: 'CONTINUE TO BED REQUIREMENTS',
              icon: Icons.arrow_forward_rounded,
              variant: intake.urgency.isCritical
                  ? BedLinkButtonVariant.critical
                  : BedLinkButtonVariant.primary,
              onPressed: intake.isFormValid
                  ? () {
                      context.go('/ambulance/requirements');
                    }
                  : null,
            ),
            const SizedBox(height: 10),

            // Secondary Action
            BedLinkButton(
              label: 'CANCEL & RETURN TO DASHBOARD',
              icon: Icons.close_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
