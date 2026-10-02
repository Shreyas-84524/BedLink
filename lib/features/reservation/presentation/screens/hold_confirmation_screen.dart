import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Hold Confirmation Placeholder Screen (Phase 7 scope).
class HoldConfirmationScreen extends StatelessWidget {
  const HoldConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'HOLD CONFIRMATION',
      subtitle: 'Step 4 of 5 • 2-Min Lock Protocol',
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
                      Text('WORKFLOW STEP 04', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 7 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2-Minute Server-Authoritative Bed Hold & Fallback',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Realtime offer lifecycle countdown, hospital triage desk response, and automatic sequential fallback progression.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'START EN-ROUTE NAVIGATION',
              icon: Icons.navigation_outlined,
              variant: BedLinkButtonVariant.primary,
              onPressed: () => context.go('/ambulance/navigation'),
            ),
            const SizedBox(height: 10),
            BedLinkButton(
              label: 'BACK TO HOSPITAL MATCHES',
              icon: Icons.arrow_back_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance/hospitals'),
            ),
          ],
        ),
      ),
    );
  }
}
