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
import '../widgets/hospital_hold_card.dart';

/// Hospital Active Holds & Reservations Screen (Phase 8).
/// Manages active bed reservations, en-route ambulance tracking, and emergency bay readiness.
class HospitalHoldsScreen extends ConsumerWidget {
  const HospitalHoldsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hospitalStateProvider);
    final holds = state.activeHolds;

    return AppScaffold(
      title: 'ACTIVE HOLDS',
      subtitle: '${state.hospitalName} • Inbound Transit',
      actions: [
        IconButton(
          icon: const Icon(Icons.inbox_outlined),
          tooltip: 'View Incoming Requests',
          onPressed: () => context.go('/hospital/requests'),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Guidance Card
          BedLinkCard(
            variant: BedLinkCardVariant.highlighted,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 20, color: AppColors.secondaryTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'CONFIRMED INBOUND RESERVATIONS',
                              style: AppTypography.operationalLabel.copyWith(
                                color: AppColors.secondaryTeal,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          BedLinkBadge(
                            label: '${state.activeHoldCount} INBOUND',
                            backgroundColor: state.activeHoldCount > 0 ? AppColors.tealSurface : AppColors.surfaceSubtle,
                            textColor: state.activeHoldCount > 0 ? AppColors.tealDark : AppColors.textPrimary,
                            borderColor: state.activeHoldCount > 0 ? AppColors.tealBorder : AppColors.border,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Held beds are locked and temporarily deducted from available capacity to prevent double-booking while ambulances are in transit.',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Holds List
          if (holds.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('NO ACTIVE BED HOLDS', style: AppTypography.cardTitle),
                  const SizedBox(height: 6),
                  Text(
                    'No ambulances currently en route with confirmed reservations. Check incoming requests to review pending emergency offers.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  BedLinkButton(
                    label: 'REVIEW INCOMING REQUESTS',
                    icon: Icons.notifications_active_outlined,
                    variant: BedLinkButtonVariant.primary,
                    onPressed: () => context.go('/hospital/requests'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...holds.map((hold) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HospitalHoldCard(hold: hold),
                )),
          ],
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
}
