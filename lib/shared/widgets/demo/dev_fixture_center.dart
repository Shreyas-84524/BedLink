import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/supabase_client_provider.dart';
import '../../../core/services/location/location_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/mock_emergency_coordinator.dart';
import '../badges/bedlink_badge.dart';
import '../buttons/bedlink_button.dart';
import '../cards/bedlink_card.dart';

/// Consolidated development-only Fixture Center bottom sheet for demonstrating
/// end-to-end ambulance ↔ hospital workflows, resilience states, and fast navigation (Phase 10).
class DevFixtureCenter extends ConsumerWidget {
  const DevFixtureCenter({super.key});

  /// Displays the DevFixtureCenter bottom sheet.
  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DevFixtureCenter(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(supabaseConfigProvider);
    if (!config.useMock) {
      return const SizedBox.shrink();
    }

    final connectivity = ref.watch(connectivityProvider);
    final connNotifier = ref.read(connectivityProvider.notifier);
    final coordinator = ref.read(mockEmergencyCoordinatorProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: AppColors.borderStrong, width: 2)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Row(
              children: [
                const Icon(Icons.tune_rounded, size: 20, color: AppColors.primarySlate),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'DEV FIXTURE CENTER',
                    style: AppTypography.operationalLabel.copyWith(
                      color: AppColors.primarySlate,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const BedLinkBadge(
                  label: 'PHASE 10 FROZEN',
                  backgroundColor: AppColors.surfaceSubtle,
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.border,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Interactive controls for offline resilience, cross-role coordination, and role jumping.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),

            // Section 1: Network Resilience Controls
            _buildSectionHeader(Icons.wifi_rounded, 'NETWORK CONNECTIVITY SIMULATION'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChoiceChip(
                  label: 'ONLINE (MED-NET)',
                  isSelected: connectivity.isOnline,
                  color: AppColors.secondaryTeal,
                  onTap: () => connNotifier.setOnline(),
                ),
                _buildChoiceChip(
                  label: 'OFFLINE (CACHE)',
                  isSelected: connectivity.isOffline,
                  color: AppColors.warningDark,
                  onTap: () => connNotifier.setOffline(),
                ),
                _buildChoiceChip(
                  label: 'RECONNECTING',
                  isSelected: connectivity.isReconnecting,
                  color: AppColors.infoBlue,
                  onTap: () => connNotifier.setReconnecting(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Section 2: Cross-Role Coordination Shortcuts
            _buildSectionHeader(Icons.sync_alt_rounded, 'AMBULANCE ↔ HOSPITAL COORDINATION'),
            const SizedBox(height: 8),
            BedLinkCard(
              variant: BedLinkCardVariant.muted,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('1. Sync Active Ambulance Request → Hospital Desk'),
                    onPressed: () {
                      coordinator.syncAmbulanceRequestToHospital();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Synced active ambulance hold to hospital incoming requests.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('2. Simulate Hospital Accept & Lock Bed'),
                    onPressed: () {
                      coordinator.hospitalAcceptsAmbulanceHold('HLD-2026-9481');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hospital accepted hold: ambulance hold locked & bed allocated.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.local_hospital_rounded, size: 16),
                    label: const Text('3. Simulate Patient Arrival (Held → Occupied)'),
                    onPressed: () {
                      coordinator.ambulanceArrivesAtHospital('HLD-2026-9481');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Arrival recorded: held bed converted to occupied.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: Direct Role Route Jumpers
            _buildSectionHeader(Icons.alt_route_rounded, 'RAPID SCREEN JUMPERS'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildNavChip(context, 'Intake', '/ambulance/intake'),
                _buildNavChip(context, 'Requirements', '/ambulance/requirements'),
                _buildNavChip(context, 'Matches', '/ambulance/hospitals'),
                _buildNavChip(context, 'Hold Status', '/ambulance/hold'),
                _buildNavChip(context, 'Navigation', '/ambulance/navigation'),
                _buildNavChip(context, 'Hospital Dashboard', '/hospital'),
                _buildNavChip(context, 'Hospital Resources', '/hospital/resources'),
                _buildNavChip(context, 'Incoming Requests', '/hospital/requests'),
                _buildNavChip(context, 'Active Holds', '/hospital/holds'),
              ],
            ),
            const SizedBox(height: 16),

            // Section 4: Location & GPS Diagnostics (Phase 13)
            _buildSectionHeader(Icons.my_location_rounded, 'LOCATION & GPS DIAGNOSTICS'),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, _) {
                final locationRepo = ref.watch(locationRepositoryProvider);
                final locState = ref.watch(ambulanceLocationProvider);

                return BedLinkCard(
                  variant: BedLinkCardVariant.muted,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Location Source:', style: AppTypography.caption),
                          BedLinkBadge(
                            label: locationRepo.isHardwareGps ? 'REAL GPS' : 'MOCK FIXTURE',
                            backgroundColor: locationRepo.isHardwareGps
                                ? AppColors.tealSurface
                                : AppColors.surfaceSubtle,
                            textColor: locationRepo.isHardwareGps
                                ? AppColors.tealDark
                                : AppColors.textSecondary,
                            borderColor: locationRepo.isHardwareGps
                                ? AppColors.tealBorder
                                : AppColors.border,
                            isMonospaced: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Status:', style: AppTypography.caption),
                          Text(
                            locState.status.name.toUpperCase(),
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          const Text('Coordinates:', style: AppTypography.caption),
                          Text(
                            locState.location != null
                                ? '${locState.location!.latitude.toStringAsFixed(4)}, ${locState.location!.longitude.toStringAsFixed(4)}'
                                : 'UNACQUIRED / NONE',
                            style: AppTypography.caption.copyWith(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                      if (locState.errorMessage != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Error: ${locState.errorMessage}',
                          style: AppTypography.caption.copyWith(color: AppColors.criticalRed),
                        ),
                      ],
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Acquire / Refresh GPS Fix'),
                        onPressed: () {
                          ref
                              .read(ambulanceLocationProvider.notifier)
                              .fetchLocation(requestPermissionIfNeeded: true);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Section 5: System Reset
            _buildSectionHeader(Icons.restart_alt_rounded, 'SYSTEM WORKFLOW RESET'),
            const SizedBox(height: 8),
            BedLinkButton(
              label: 'RESET EMERGENCY WORKFLOW',
              icon: Icons.refresh_rounded,
              variant: BedLinkButtonVariant.secondary,
              onPressed: () {
                coordinator.resetFullEmergencySystem();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency triage and navigation workflow cleanly reset.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: AppTypography.operationalLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? color : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildNavChip(BuildContext context, String label, String route) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.go(route);
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
