import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Ambulance Patient Intake Placeholder Screen (Phase 4 scope).
class PatientIntakeScreen extends StatelessWidget {
  const PatientIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'PATIENT INTAKE',
      subtitle: 'Step 1 of 5 • Triage & Vitals',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BedLinkCard(
              variant: BedLinkCardVariant.highlighted,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('WORKFLOW STEP 01', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 4 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Patient Demographics, Urgency & Vitals Assessment',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Fast mobile data entry form for patient age, sex, chief complaints, Glasgow Coma Scale (GCS), systolic BP, heart rate, and SpO2.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'CONTINUE TO BED REQUIREMENTS',
              icon: Icons.arrow_forward_rounded,
              variant: BedLinkButtonVariant.primary,
              onPressed: () => context.go('/ambulance/requirements'),
            ),
            const SizedBox(height: 10),
            BedLinkButton(
              label: 'BACK TO AMBULANCE DASHBOARD',
              icon: Icons.dashboard_outlined,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance'),
            ),
          ],
        ),
      ),
    );
  }
}
