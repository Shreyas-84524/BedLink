import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Hospital Resource Inventory & Freshness Screen (Phase 8 scope).
class HospitalResourcesScreen extends StatelessWidget {
  const HospitalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'RESOURCE INVENTORY',
      subtitle: 'Capacity Management & Freshness',
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
                      Text('HOSPITAL MODULE 01', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 8 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bed Availability & Fast Capacity Steppers',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Immediate ± counters for ICU, Oxygen, and General beds. One-tap "CONFIRM NO CHANGE" button to keep freshness age fresh (<30 min).',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Spacer(),
            BedLinkButton(
              label: 'BACK TO HOSPITAL DASHBOARD',
              icon: Icons.dashboard_outlined,
              variant: BedLinkButtonVariant.primary,
              onPressed: () => context.go('/hospital'),
            ),
          ],
        ),
      ),
    );
  }
}
