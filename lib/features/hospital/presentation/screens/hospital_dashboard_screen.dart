import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/badges/status_badges.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/buttons/bedlink_icon_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/cards/bedlink_metric_card.dart';
import '../../../../shared/widgets/chrome/bedlink_app_bar.dart';
import '../providers/hospital_state_provider.dart';

/// Hospital Staff Application Shell & Operational Triage Center Screen.
class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final hospitalState = ref.watch(hospitalStateProvider);

    final hospitalName = session.organizationName ?? hospitalState.hospitalName;
    final staffName = session.displayName ?? hospitalState.staffName;

    final icuAvail = hospitalState.resources['icu_bed']?.available ?? 0;
    final oxygenAvail = hospitalState.resources['oxygen_bed']?.available ?? 0;
    final erAvail = hospitalState.resources['er_bed']?.available ?? 0;

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
                      HospitalLoadBadge(
                        state: hospitalState.loadState,
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FreshnessBadge(state: hospitalState.overallFreshnessState),
                          const SizedBox(width: 6),
                          Text(
                            hospitalState.minutesSinceLastConfirmed <= 0
                                ? 'JUST NOW'
                                : '${hospitalState.minutesSinceLastConfirmed}M AGO',
                            style: AppTypography.operationalLabel.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ref.read(hospitalStateProvider.notifier).confirmNoChange();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bed inventory confirmed with no changes. Freshness updated.'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tealSurface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.tealBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, size: 13, color: AppColors.tealDark),
                              const SizedBox(width: 4),
                              Text(
                                'CONFIRM NO CHANGE',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.tealDark,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
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
            Row(
              children: [
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'ICU BEDS',
                    value: icuAvail.toString().padLeft(2, '0'),
                    unit: 'AVAIL',
                    icon: Icons.monitor_heart_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'O2 BEDS',
                    value: oxygenAvail.toString().padLeft(2, '0'),
                    unit: 'AVAIL',
                    icon: Icons.air_outlined,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BedLinkMetricCard(
                    label: 'TRAUMA',
                    value: erAvail.toString().padLeft(2, '0'),
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
              badgeLabel: '${(hospitalState.totalOccupancyRate * 100).toInt()}% OCCUPIED',
              accentColor: AppColors.secondaryTeal,
            ),
            const SizedBox(height: 8),

            _buildModuleCard(
              context: context,
              title: 'Incoming Emergency Requests',
              subtitle: 'Review incoming 2-minute candidate offers and accept/decline triage calls.',
              route: '/hospital/requests',
              icon: Icons.notifications_active_outlined,
              badgeLabel: hospitalState.pendingRequestCount > 0
                  ? '${hospitalState.pendingRequestCount} PENDING'
                  : 'NONE PENDING',
              badgeBg: hospitalState.pendingRequestCount > 0 ? AppColors.warningSurface : AppColors.surfaceSubtle,
              badgeTextColor: hospitalState.pendingRequestCount > 0 ? AppColors.warningDark : AppColors.textPrimary,
              badgeBorder: hospitalState.pendingRequestCount > 0 ? AppColors.warningBorder : AppColors.border,
              accentColor: AppColors.warningAmber,
            ),
            const SizedBox(height: 8),

            _buildModuleCard(
              context: context,
              title: 'Active Holds & Inbound Transit',
              subtitle: 'Monitor accepted bed holds, live ambulance ETAs, and prepare trauma bays.',
              route: '/hospital/holds',
              icon: Icons.bookmark_added_outlined,
              badgeLabel: hospitalState.activeHoldCount > 0
                  ? '${hospitalState.activeHoldCount} INBOUND'
                  : '0 ACTIVE',
              badgeBg: hospitalState.activeHoldCount > 0 ? AppColors.tealSurface : AppColors.surfaceSubtle,
              badgeTextColor: hospitalState.activeHoldCount > 0 ? AppColors.tealDark : AppColors.textPrimary,
              badgeBorder: hospitalState.activeHoldCount > 0 ? AppColors.tealBorder : AppColors.border,
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
    required String badgeLabel,
    Color badgeBg = AppColors.surfaceSubtle,
    Color badgeTextColor = AppColors.textPrimary,
    Color badgeBorder = AppColors.border,
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
                      label: badgeLabel,
                      backgroundColor: badgeBg,
                      textColor: badgeTextColor,
                      borderColor: badgeBorder,
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
