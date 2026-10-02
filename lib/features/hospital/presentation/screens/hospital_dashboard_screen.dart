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
import '../../../../shared/widgets/cards/bedlink_metric_card.dart';
import '../../../../shared/widgets/chrome/bedlink_app_bar.dart';

/// Hospital Staff Application Shell & Operational Triage Center Screen.
class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final hospitalName = session.organizationName ?? 'KEM Hospital Mumbai';
    final staffName = session.displayName ?? 'Dr. A. Mehta (Triage Lead)';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BedLinkAppBar(
        title: 'HOSPITAL TRIAGE DESK',
        showLiveBadge: true,
        actions: [
          BedLinkIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Sign Out of Hospital Shell',
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
            // Hospital Header Context Card
            BedLinkCard(
              variant: BedLinkCardVariant.highlighted,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hospitalName.toUpperCase(),
                              style: AppTypography.operationalDataBold.copyWith(
                                fontSize: 15,
                                color: AppColors.primarySlate,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              staffName,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const HospitalLoadBadge(
                        state: HospitalLoadState.low,
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const FreshnessBadge(state: FreshnessState.fresh),
                      Text(
                        'CAMPUS: PAREL • ZONE 2',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Capacity Summary Strip
            const Text('LIVE EMERGENCY CAPACITY SNAPSHOT', style: AppTypography.operationalLabel),
            const SizedBox(height: 8),
            const Row(
              children: [
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'ICU BEDS',
                    value: '04',
                    unit: 'AVAIL',
                    icon: Icons.monitor_heart_outlined,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'O2 BEDS',
                    value: '12',
                    unit: 'AVAIL',
                    icon: Icons.air_outlined,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'TRAUMA',
                    value: '02',
                    unit: 'AVAIL',
                    icon: Icons.emergency_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hospital Staff Operational Sections (Phase 8 Modules)
            const Text('HOSPITAL OPERATIONAL MODULES (PHASE 8)', style: AppTypography.operationalLabel),
            const SizedBox(height: 8),

            _buildModuleCard(
              context: context,
              title: 'Resource Inventory & Capacity',
              subtitle: 'Update ICU, Oxygen, and Trauma bed counts with quick ± counters.',
              route: '/hospital/resources',
              icon: Icons.inventory_2_outlined,
              badgeText: 'PHASE 8',
              accentColor: AppColors.secondaryTeal,
            ),
            const SizedBox(height: 8),

            _buildModuleCard(
              context: context,
              title: 'Incoming Emergency Requests',
              subtitle: 'Review incoming 2-minute candidate offers and accept/decline triage calls.',
              route: '/hospital/requests',
              icon: Icons.notifications_active_outlined,
              badgeText: 'PHASE 8',
              accentColor: AppColors.warningAmber,
            ),
            const SizedBox(height: 8),

            _buildModuleCard(
              context: context,
              title: 'Active Holds & Inbound Transit',
              subtitle: 'Monitor accepted bed holds, live ambulance ETAs, and prepare trauma bays.',
              route: '/hospital/holds',
              icon: Icons.bookmark_added_outlined,
              badgeText: 'PHASE 8',
              accentColor: AppColors.infoBlue,
            ),
            const SizedBox(height: 16),

            // Quick Action to update inventory
            BedLinkButton(
              label: 'MANAGE BED INVENTORY (PHASE 8)',
              icon: Icons.edit_note_rounded,
              variant: BedLinkButtonVariant.available,
              onPressed: () => context.go('/hospital/resources'),
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

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String route,
    required IconData icon,
    required String badgeText,
    required Color accentColor,
  }) {
    return BedLinkCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: accentColor),
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
                      label: badgeText,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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
