import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Navigation & Arrival Screen (Phase 9 & 14 scope).
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'TRANSIT NAVIGATION',
      subtitle: 'Step 5 of 5 • Destination Guidance',
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
                      Expanded(
                        child: Text(
                          'WORKFLOW STEP 05',
                          style: AppTypography.operationalLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8),
                      BedLinkBadge(
                        label: 'PHASE 9 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Live Vector Route Map & One-Tap Arrival Protocol',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'MapLibre GL vector guidance with Mumbai traffic routing, persistent ETA readout, and single-transaction arrival confirmation.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'CONFIRM ARRIVAL AT HOSPITAL',
              icon: Icons.check_circle_outline_rounded,
              variant: BedLinkButtonVariant.available,
              onPressed: () => context.go('/ambulance'),
            ),
            const SizedBox(height: 10),
            BedLinkButton(
              label: 'BACK TO HOLD STATUS',
              icon: Icons.arrow_back_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance/hold'),
            ),
          ],
        ),
      ),
    );
  }
}
