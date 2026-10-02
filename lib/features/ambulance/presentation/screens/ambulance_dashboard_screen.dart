import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/badges/status_badges.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/buttons/bedlink_icon_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/chrome/bedlink_app_bar.dart';

/// Ambulance Application Shell & Operational Dashboard Screen.
class AmbulanceDashboardScreen extends ConsumerWidget {
  const AmbulanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final unitTitle = session.organizationName ?? 'Mumbai EMS Unit 101';
    final crewLeader = session.displayName ?? 'Crew Lead (Dadar)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BedLinkAppBar(
        title: 'AMBULANCE DISPATCH',
        showLiveBadge: true,
        actions: [
          BedLinkIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Sign Out of Ambulance Shell',
            color: AppColors.textPrimary,
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // Active Unit & Shift Context Card
            BedLinkCard(
              variant: BedLinkCardVariant.highlighted,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unitTitle.toUpperCase(),
                              style: AppTypography.operationalDataBold.copyWith(
                                fontSize: 15,
                                color: AppColors.primarySlate,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              crewLeader,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const AvailabilityBadge(
                        state: AvailabilityState.available,
                        customLabel: 'ON DUTY • STANDBY',
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildTelemetryItem(
                        icon: Icons.gps_fixed_rounded,
                        label: 'GPS LOCK',
                        value: 'DADAR • ZONE 2',
                      ),
                      _buildTelemetryItem(
                        icon: Icons.wifi_tethering_rounded,
                        label: 'MED-NET LINK',
                        value: '5G • 18ms',
                        isGood: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Emergency Dispatch Primary Action
            const Text('ACTIVE EMERGENCY ACTIONS', style: AppTypography.operationalLabel),
            const SizedBox(height: 8),
            BedLinkButton(
              label: 'START NEW PATIENT INTAKE',
              icon: Icons.add_alert_rounded,
              variant: BedLinkButtonVariant.critical,
              onPressed: () => context.go('/ambulance/intake'),
            ),
            const SizedBox(height: 16),

            // Sequential Workflow Step Navigation
            const Text('EMERGENCY DISPATCH WORKFLOW (PHASES 4–9)', style: AppTypography.operationalLabel),
            const SizedBox(height: 8),

            _buildWorkflowCard(
              context: context,
              stepNumber: '01',
              title: 'Patient Intake & Triage',
              description: 'Record vitals, Glasgow Coma Scale, chief complaints, and urgency level.',
              route: '/ambulance/intake',
              badgeLabel: 'PHASE 4',
              icon: Icons.personal_injury_outlined,
            ),
            const SizedBox(height: 8),

            _buildWorkflowCard(
              context: context,
              stepNumber: '02',
              title: 'Bed Need Assessment',
              description: 'Select required bed types (ICU, Trauma, O2) and specialist requirements.',
              route: '/ambulance/requirements',
              badgeLabel: 'PHASE 5',
              icon: Icons.hotel_outlined,
            ),
            const SizedBox(height: 8),

            _buildWorkflowCard(
              context: context,
              stepNumber: '03',
              title: 'Hospital Match Grid',
              description: 'View ranked nearby Mumbai hospitals filtered by capability & road ETA.',
              route: '/ambulance/hospitals',
              badgeLabel: 'PHASE 6',
              icon: Icons.hub_outlined,
            ),
            const SizedBox(height: 8),

            _buildWorkflowCard(
              context: context,
              stepNumber: '04',
              title: 'Hold Confirmation',
              description: 'Track 2-minute temporary bed reservation and hospital acceptance.',
              route: '/ambulance/hold',
              badgeLabel: 'PHASE 7',
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: 8),

            _buildWorkflowCard(
              context: context,
              stepNumber: '05',
              title: 'En-Route Navigation',
              description: 'Turn-by-turn guidance to accepted hospital and one-tap arrival confirmation.',
              route: '/ambulance/navigation',
              badgeLabel: 'PHASE 9',
              icon: Icons.navigation_outlined,
            ),
            const SizedBox(height: 16),

            // Footer Quick Link
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.palette_outlined, size: 16),
                label: const Text('View Design System Catalog'),
                onPressed: () => context.go('/design-system'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem({
    required IconData icon,
    required String label,
    required String value,
    bool isGood = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: isGood ? AppColors.secondaryTeal : AppColors.textSecondary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.operationalLabel.copyWith(fontSize: 9)),
            Text(
              value,
              style: AppTypography.operationalDataBold.copyWith(
                fontSize: 11,
                color: isGood ? AppColors.secondaryTeal : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkflowCard({
    required BuildContext context,
    required String stepNumber,
    required String title,
    required String description,
    required String route,
    required String badgeLabel,
    required IconData icon,
  }) {
    return BedLinkCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              stepNumber,
              style: AppTypography.operationalDataBold.copyWith(
                color: AppColors.primarySlate,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.cardTitle.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    BedLinkBadge(
                      label: badgeLabel,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
