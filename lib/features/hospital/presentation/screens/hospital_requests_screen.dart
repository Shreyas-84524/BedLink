import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';

/// Hospital Incoming Emergency Offers Screen (Phase 8 scope).
class HospitalRequestsScreen extends StatelessWidget {
  const HospitalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'INCOMING REQUESTS',
      subtitle: 'Triage Offers & Emergency Alerts',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const BedLinkCard(
              variant: BedLinkCardVariant.critical,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('HOSPITAL MODULE 02', style: AppTypography.operationalLabel),
                      BedLinkBadge(
                        label: 'PHASE 8 SCOPE',
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2-Minute Candidate Triage Offers & Divert Alerts',
                    style: AppTypography.cardTitle,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'High-visibility triage request card showing inbound patient acuity, required bed type, and 120s server countdown timer with Accept / Divert actions.',
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
