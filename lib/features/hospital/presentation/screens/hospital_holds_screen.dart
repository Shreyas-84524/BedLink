import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Hospital Active Holds & Reservations Screen (Phase 8 scope).
class HospitalHoldsScreen extends StatelessWidget {
  const HospitalHoldsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'ACTIVE HOLDS',
      subtitle: 'Inbound Patient Tracking',
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
                      Text('HOSPITAL MODULE 03', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 8 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Confirmed Bed Holds & Live En-Route Ambulance Tracking',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'List of active temporary reservations, assigned bed IDs, incoming ambulance callsigns, and countdown to ER arrival for bay preparation.',
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
