import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/supabase_client_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../ambulance/domain/models/clinical_resource_catalogue.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../domain/models/hold_status.dart';
import '../providers/hold_timer_provider.dart';
import '../widgets/circular_countdown.dart';
import '../widgets/fallback_progress_tracker.dart';
import '../widgets/inbound_patient_summary_card.dart';
import '../widgets/mock_offer_controller_drawer.dart';
import '../widgets/target_hospital_hold_card.dart';

/// Complete Two-Minute Hold & Confirmation Screen (Phase 7 scope).
///
/// Demonstrates the simulated 120-second offer lifecycle, hospital triage desk response,
/// locked bed reservation, and automated sequential fallback routing.
class HoldConfirmationScreen extends ConsumerWidget {
  const HoldConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final offer = ref.watch(holdTimerProvider);
    final notifier = ref.read(holdTimerProvider.notifier);
    final requirements = ref.watch(bedRequirementProvider);

    // Collect clinical resource labels from Phase 5
    final requiredResourceLabels = <String>[];
    for (final entry in requirements.selectedRequirements.entries) {
      final res = ClinicalResourceCatalogue.findById(entry.key);
      if (res != null) {
        if (res.isCountable) {
          requiredResourceLabels.add('${entry.value}× ${res.shortLabel}');
        } else {
          requiredResourceLabels.add(res.shortLabel);
        }
      }
    }

    return AppScaffold(
      title: 'HOLD CONFIRMATION',
      subtitle: 'Step 4 of 5 • 2-Min Lock Protocol',
      actions: [
        if (selectedHospital != null)
          IconButton(
            tooltip: 'Restart Hold Timer',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.secondaryTeal),
            onPressed: () => notifier.startHold(),
          ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Safe Recovery State: No Hospital Selected
              if (selectedHospital == null || offer == null) ...[
                _buildMissingHospitalCard(context),
              ] else ...[
                // 7.6 & 7.7 Top Lifecycle Banner
                _buildLifecycleBanner(offer.status, offer.hospital.name, offer.rejectionReason),
                const SizedBox(height: 14),

                // 7.2 Circular Countdown Clock (monospaced, smooth 1s updates, color warnings)
                CircularHoldCountdown(
                  remainingSeconds: offer.remainingSeconds,
                  status: offer.status,
                ),
                const SizedBox(height: 16),

                // 7.3 Target Hospital & Held Bed Card
                TargetHospitalHoldCard(
                  hospital: offer.hospital,
                  status: offer.status,
                  requiredResourceLabels: requiredResourceLabels,
                  onCallHospital: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Simulated Call: Connecting to ${offer.hospital.emergencyPhone}...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),

                // 7.4 Inbound Patient Clinical Summary Card
                const InboundPatientSummaryCard(),
                const SizedBox(height: 14),

                // 7.5 Automatic Safety Fallback Panel
                FallbackProgressTracker(
                  currentHospital: offer.hospital,
                  fallbackHospital: offer.fallbackHospital,
                  status: offer.status,
                  onAdvanceToFallback: () => notifier.advanceToFallback(),
                ),
                const SizedBox(height: 14),

                // Simulation Controls for Demo & Test Automation (Mock Mode Only)
                if (ref.watch(supabaseConfigProvider).useMock) ...[
                  MockOfferControllerBar(notifier: notifier),
                  const SizedBox(height: 16),
                ],

                // Primary Dynamic Actions
                if (offer.status.isAccepted) ...[
                  BedLinkButton(
                    label: 'START EN-ROUTE NAVIGATION',
                    icon: Icons.navigation_rounded,
                    variant: BedLinkButtonVariant.available,
                    onPressed: () => context.go('/ambulance/navigation'),
                  ),
                ] else if (offer.status.isRejected || offer.status.isTimedOut) ...[
                  if (offer.fallbackHospital != null) ...[
                    BedLinkButton(
                      label: 'OFFER TO ${offer.fallbackHospital!.name.toUpperCase()}',
                      icon: Icons.alt_route_rounded,
                      variant: BedLinkButtonVariant.available,
                      onPressed: () => notifier.advanceToFallback(),
                    ),
                    const SizedBox(height: 8),
                  ],
                  BedLinkButton(
                    label: 'RETURN TO HOSPITAL MATCHES',
                    icon: Icons.arrow_back_rounded,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () => context.go('/ambulance/hospitals'),
                  ),
                ] else ...[
                  BedLinkButton(
                    label: 'CANCEL HOLD REQUEST',
                    icon: Icons.close_rounded,
                    variant: BedLinkButtonVariant.secondary,
                    onPressed: () => context.go('/ambulance/hospitals'),
                  ),
                ],
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissingHospitalCard(BuildContext context) {
    return BedLinkCard(
      variant: BedLinkCardVariant.warning,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warningAmber,
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'NO HOSPITAL SELECTED',
            style: AppTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'A target hospital candidate must be chosen from the discovery match grid before initiating the 2-minute bed hold protocol.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          BedLinkButton(
            label: 'BACK TO HOSPITAL MATCHES',
            icon: Icons.arrow_back_rounded,
            variant: BedLinkButtonVariant.primary,
            onPressed: () => context.go('/ambulance/hospitals'),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleBanner(
    HoldLifecycleState status,
    String hospitalName,
    String? rejectionReason,
  ) {
    switch (status) {
      case HoldLifecycleState.accepted:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.tealSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.secondaryTeal, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.secondaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BED HOLD CONFIRMED • LOCKED',
                      style: AppTypography.operationalDataBold.copyWith(
                        color: AppColors.tealDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$hospitalName accepted the emergency hold. Resources are locked for transit.',
                      style: AppTypography.caption.copyWith(color: AppColors.tealDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case HoldLifecycleState.rejected:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.criticalSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.criticalBorder, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cancel_rounded,
                color: AppColors.criticalRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOLD REQUEST DECLINED',
                      style: AppTypography.operationalDataBold.copyWith(
                        color: AppColors.criticalDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rejectionReason ?? '$hospitalName unable to accept due to department surge.',
                      style: AppTypography.caption.copyWith(color: AppColors.criticalDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case HoldLifecycleState.timedOut:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.criticalSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.criticalBorder, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.timer_off_rounded,
                color: AppColors.criticalRed,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOLD WINDOW EXPIRED (120S)',
                      style: AppTypography.operationalDataBold.copyWith(
                        color: AppColors.criticalDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'No response received from $hospitalName triage desk. Ready for fallback advance.',
                      style: AppTypography.caption.copyWith(color: AppColors.criticalDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case HoldLifecycleState.fallbackTransition:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.warningBorder, width: 1.2),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: AppColors.warningDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ROUTING TO NEXT CANDIDATE',
                      style: AppTypography.operationalDataBold.copyWith(
                        color: AppColors.warningDark,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sequential automatic fallback protocol active.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case HoldLifecycleState.pending:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Holding beds for review at $hospitalName triage desk...',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
