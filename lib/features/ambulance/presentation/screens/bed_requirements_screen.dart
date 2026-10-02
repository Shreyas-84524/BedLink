import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Ambulance Bed Need Assessment Placeholder Screen (Phase 5 scope).
class BedRequirementsScreen extends StatelessWidget {
  const BedRequirementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'BED REQUIREMENTS',
      subtitle: 'Step 2 of 5 • Resource Selection',
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
                      Text('WORKFLOW STEP 02', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 5 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Clinical Resource & Specialist Requirements',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Interactive selection for ICU Bed, Oxygen Bed, Trauma Bay, Ventilator, and required specialties (Cardiology, Neurosurgery, Burn Unit, Pediatric).',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'DISCOVER MATCHING HOSPITALS',
              icon: Icons.hub_outlined,
              variant: BedLinkButtonVariant.primary,
              onPressed: () => context.go('/ambulance/hospitals'),
            ),
            const SizedBox(height: 10),
            BedLinkButton(
              label: 'BACK TO INTAKE',
              icon: Icons.arrow_back_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance/intake'),
            ),
          ],
        ),
      ),
    );
  }
}
