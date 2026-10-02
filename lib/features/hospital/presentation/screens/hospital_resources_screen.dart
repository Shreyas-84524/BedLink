import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/hospital_state_provider.dart';
import '../widgets/hospital_freshness_bar.dart';
import '../widgets/hospital_resource_card.dart';

/// Hospital Resource Inventory & Fast Capacity Management Screen (Phase 8).
class HospitalResourcesScreen extends ConsumerWidget {
  const HospitalResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hospitalStateProvider);

    final criticalCareItems = state.resources.values
        .where((r) => r.category == 'Critical Care')
        .toList();
    final acuteEmergencyItems = state.resources.values
        .where((r) => r.category == 'Acute & Emergency')
        .toList();
    final specializedItems = state.resources.values
        .where((r) => r.category == 'Specialized Capabilities')
        .toList();

    final occupancyPercent = (state.totalOccupancyRate * 100).toInt();

    return AppScaffold(
      title: 'RESOURCE INVENTORY',
      subtitle: '${state.hospitalName} • Live Capacity',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Reset Fixture Baseline',
          onPressed: () {
            ref.read(hospitalStateProvider.notifier).resetDemoFixture();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventory reset to initial demonstration baseline.'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Freshness Header & Quick Confirm Action
          const HospitalFreshnessBar(),
          const SizedBox(height: 12),

          // Aggregate Capacity Summary Card
          BedLinkCard(
            variant: BedLinkCardVariant.defaultCard,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'TOTAL BED OCCUPANCY',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.primarySlate,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BedLinkBadge(
                      label: '$occupancyPercent% IN USE',
                      backgroundColor: occupancyPercent >= 85
                          ? AppColors.criticalSurface
                          : occupancyPercent >= 65
                              ? AppColors.warningSurface
                              : AppColors.tealSurface,
                      textColor: occupancyPercent >= 85
                          ? AppColors.criticalRed
                          : occupancyPercent >= 65
                              ? AppColors.warningDark
                              : AppColors.tealDark,
                      borderColor: occupancyPercent >= 85
                          ? AppColors.criticalBorder
                          : occupancyPercent >= 65
                              ? AppColors.warningBorder
                              : AppColors.tealBorder,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: state.totalOccupancyRate,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      occupancyPercent >= 85
                          ? AppColors.criticalRed
                          : occupancyPercent >= 65
                              ? AppColors.warningAmber
                              : AppColors.secondaryTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Immediate changes made below directly propagate to live ambulance dispatch and recommendation rankings.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 1: Critical Care Beds
          _buildCategoryHeader(
            title: 'CRITICAL CARE INVENTORY',
            icon: Icons.monitor_heart_outlined,
            color: AppColors.criticalRed,
          ),
          const SizedBox(height: 8),
          ...criticalCareItems.map((res) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HospitalResourceCard(resource: res),
              )),
          const SizedBox(height: 12),

          // Section 2: Acute & Emergency Beds
          _buildCategoryHeader(
            title: 'ACUTE & EMERGENCY CARE',
            icon: Icons.emergency_outlined,
            color: AppColors.secondaryTeal,
          ),
          const SizedBox(height: 8),
          ...acuteEmergencyItems.map((res) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HospitalResourceCard(resource: res),
              )),
          const SizedBox(height: 12),

          // Section 3: Specialized Capabilities
          _buildCategoryHeader(
            title: 'SPECIALIZED CLINICAL UNITS',
            icon: Icons.local_hospital_outlined,
            color: AppColors.primarySlate,
          ),
          const SizedBox(height: 8),
          ...specializedItems.map((res) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HospitalResourceCard(resource: res),
              )),
          const SizedBox(height: 16),

          // Return to dashboard button
          BedLinkButton(
            label: 'BACK TO HOSPITAL DASHBOARD',
            icon: Icons.dashboard_outlined,
            variant: BedLinkButtonVariant.secondary,
            onPressed: () => context.go('/hospital'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTypography.operationalLabel.copyWith(
            color: AppColors.primarySlate,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
