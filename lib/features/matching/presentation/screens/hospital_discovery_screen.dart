import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Hospital Match Grid & Discovery Placeholder Screen (Phase 6 scope).
class HospitalDiscoveryScreen extends StatelessWidget {
  const HospitalDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'HOSPITAL MATCHES',
      subtitle: 'Step 3 of 5 • Multi-Criteria Ranking',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BedLinkCard(
              variant: BedLinkCardVariant.recommended,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('WORKFLOW STEP 03', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 6 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ranked Hospital Grid & Real-time ORS Road ETA',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Multi-criteria scoring based on clinical fit, actual road matrix travel time, data freshness, spare capacity, and current ER load.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'CONFIRM 2-MIN BED HOLD',
              icon: Icons.timer_outlined,
              variant: BedLinkButtonVariant.available,
              onPressed: () => context.go('/ambulance/hold'),
            ),
            const SizedBox(height: 10),
            BedLinkButton(
              label: 'BACK TO REQUIREMENTS',
              icon: Icons.arrow_back_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () => context.go('/ambulance/requirements'),
            ),
          ],
        ),
      ),
    );
  }
}
