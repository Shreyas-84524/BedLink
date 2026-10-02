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
import '../widgets/hospital_request_card.dart';

/// Hospital Incoming Emergency Offers Screen (Phase 8).
/// Manages incoming candidate requests, 120-second acceptance timers, and divert workflows.
class HospitalRequestsScreen extends ConsumerWidget {
  const HospitalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hospitalStateProvider);
    final requests = state.incomingRequests;

    return AppScaffold(
      title: 'INCOMING REQUESTS',
      subtitle: '${state.hospitalName} • Emergency Triage',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_alert_outlined),
          tooltip: 'Simulate Incoming Emergency Offer',
          onPressed: () {
            ref.read(hospitalStateProvider.notifier).injectMockRequest();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Simulated new incoming emergency triage offer received.'),
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
          // Operational Guideline Banner
          BedLinkCard(
            variant: BedLinkCardVariant.highlighted,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.timer_rounded, size: 20, color: AppColors.criticalRed),
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
                              'SERVER-AUTHORITATIVE 2-MIN TIMEOUT',
                              style: AppTypography.operationalLabel.copyWith(
                                color: AppColors.criticalRed,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          BedLinkBadge(
                            label: '${state.pendingRequestCount} PENDING',
                            backgroundColor: state.pendingRequestCount > 0 ? AppColors.criticalSurface : AppColors.surfaceSubtle,
                            textColor: state.pendingRequestCount > 0 ? AppColors.criticalRed : AppColors.textPrimary,
                            borderColor: state.pendingRequestCount > 0 ? AppColors.criticalBorder : AppColors.border,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hospital staff must accept candidate patient offers within 120 seconds. If not accepted in time, BedLink automatically cascades to the next nearest ranked facility.',
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

          // Incoming Emergency Request List
          if (requests.isEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 48, color: AppColors.secondaryTeal),
                  const SizedBox(height: 12),
                  const Text('NO PENDING EMERGENCY OFFERS', style: AppTypography.cardTitle),
                  const SizedBox(height: 6),
                  Text(
                    'All inbound ambulance candidate calls have been processed. Triage desk is on standby.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  BedLinkButton(
                    label: 'SIMULATE INBOUND CALL',
                    icon: Icons.add_call,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () {
                      ref.read(hospitalStateProvider.notifier).injectMockRequest();
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            ...requests.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HospitalRequestCard(request: req),
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
