import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/location/location_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../ambulance/domain/models/patient_intake.dart';
import '../../../ambulance/presentation/providers/intake_provider.dart';
import '../../../matching/presentation/providers/selected_hospital_provider.dart';
import '../../domain/models/navigation_lifecycle.dart';
import '../providers/navigation_state_provider.dart';
import '../widgets/arrival_confirmation_card.dart';
import '../widgets/bed_held_banner.dart';
import '../widgets/bedlink_route_map.dart';
import '../widgets/completed_handoff_card.dart';
import '../widgets/confirmed_destination_card.dart';
import '../widgets/route_instruction_card.dart';

/// Navigation & Arrival Screen (Phase 9 scope).
/// Provides live turn-by-turn instruction guidance, mock vector route tracking,
/// persistent bed hold verification, and one-tap emergency bay arrival handoff.
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  bool _showDevControls = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationStateProvider.notifier).loadRealDirections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedHospital = ref.watch(selectedHospitalProvider);
    final patient = ref.watch(patientIntakeProvider);
    final navState = ref.watch(navigationStateProvider);
    final navNotifier = ref.read(navigationStateProvider.notifier);
    final locState = ref.watch(ambulanceLocationProvider);

    // Fallback: If no hospital is selected in session, render safe recovery screen
    if (selectedHospital == null) {
      return AppScaffold(
        title: 'TRANSIT NAVIGATION',
        subtitle: 'Step 5 of 5 • Route Navigation',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BedLinkCard(
                variant: BedLinkCardVariant.warning,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: AppColors.warningDark,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'NO ACTIVE DESTINATION SELECTED',
                      style: AppTypography.cardTitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ambulance navigation requires a confirmed receiving hospital destination and active bed reservation hold.',
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BedLinkButton(
                label: 'GO TO HOSPITAL DISCOVERY',
                icon: Icons.local_hospital_rounded,
                variant: BedLinkButtonVariant.primary,
                onPressed: () => context.go('/ambulance/hospitals'),
              ),
              const SizedBox(height: 10),
              BedLinkButton(
                label: 'RETURN TO INTAKE',
                icon: Icons.person_add_alt_1_rounded,
                variant: BedLinkButtonVariant.secondary,
                onPressed: () => context.go('/ambulance/intake'),
              ),
            ],
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'TRANSIT NAVIGATION',
      subtitle: 'Step 5 of 5 • Destination Guidance',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Workflow Step Card with Patient Triage Strip
            _buildPatientHeader(patient, navState),
            const SizedBox(height: 12),

            // 2. High-Visibility Bed Hold Banner (or unconfirmed warning)
            const BedHeldBanner(),

            // 3. Vector Route Map Canvas (MapLibre vector tiles with tactical canvas fallback)
            BedlinkRouteMap(
              routeProgress: navState.routeProgress,
              destinationName: selectedHospital.name,
              ambulanceLatitude: locState.location?.latitude,
              ambulanceLongitude: locState.location?.longitude,
              destinationLatitude: selectedHospital.latitude,
              destinationLongitude: selectedHospital.longitude,
              routeGeometry: navState.routeGeometry,
              isRealRouting: navState.isRealRouting,
            ),
            if (navState.routingError != null && !navState.status.isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.warningDark,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live ORS routing unavailable: ${navState.routingError}. Displaying estimated navigation guidance.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warningDark,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),

            // 4. Completed Handoff Card (replaces instruction card when completed)
            if (navState.status.isCompleted) ...[
              const CompletedHandoffCard(),
            ] else ...[
              // Turn-by-Turn Route Guidance Card
              const RouteInstructionCard(),
              const SizedBox(height: 12),

              // Arrival Protocol Action Card
              const ArrivalConfirmationCard(),
              const SizedBox(height: 12),

              // Confirmed Destination & Secured Resources Summary
              const ConfirmedDestinationCard(),
              const SizedBox(height: 12),

              // Developer Testing Simulation Drawer
              _buildDevControls(navNotifier, navState),
              const SizedBox(height: 12),

              // Return to Hold Status (Manual Navigation fallback)
              BedLinkButton(
                label: 'BACK TO HOLD STATUS',
                icon: Icons.arrow_back_rounded,
                variant: BedLinkButtonVariant.secondary,
                onPressed: () => context.go('/ambulance/hold'),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(PatientIntake patient, NavigationProgressState navState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient.displayName} • ${patient.age} y/o ${patient.biologicalSex.label}',
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  patient.chiefComplaint.isNotEmpty
                      ? patient.chiefComplaint
                      : 'Emergency Triage En Route',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          BedLinkBadge(
            label: navState.status.label,
            backgroundColor: navState.status.isArrived || navState.status.isCompleted
                ? AppColors.tealSurface
                : AppColors.surface,
            textColor: navState.status.isArrived || navState.status.isCompleted
                ? AppColors.tealDark
                : AppColors.primarySlate,
            borderColor: navState.status.isArrived || navState.status.isCompleted
                ? AppColors.tealBorder
                : AppColors.borderStrong,
          ),
        ],
      ),
    );
  }

  Widget _buildDevControls(
    NavigationStateNotifier navNotifier,
    NavigationProgressState navState,
  ) {
    return BedLinkCard(
      variant: BedLinkCardVariant.muted,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showDevControls = !_showDevControls;
              });
            },
            child: Row(
              children: [
                const Icon(
                  Icons.bug_report_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'DEVELOPER TRANSIT FIXTURES',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _showDevControls ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (_showDevControls) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => navNotifier.advanceProgress(),
                  child: const Text('Advance Step (+1)', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => navNotifier.simulateNearArrival(),
                  child: const Text('Simulate Bay (<1m)', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => navNotifier.simulateArrived(),
                  child: const Text('Simulate Arrived', style: TextStyle(fontSize: 11)),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  onPressed: () => navNotifier.completeHandoff(),
                  child: const Text('Simulate Handoff', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
