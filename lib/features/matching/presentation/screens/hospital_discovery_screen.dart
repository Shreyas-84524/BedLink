import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../domain/models/hospital_match.dart';
import '../providers/matching_provider.dart';
import '../providers/selected_hospital_provider.dart';
import '../widgets/hospital_match_tile.dart';
import '../widgets/matching_search_indicator.dart';
import '../widgets/patient_requirement_summary_bar.dart';
import '../widgets/primary_hospital_card.dart';

/// Hospital Discovery & Match Grid Screen (Phase 6 scope).
///
/// Displays ranked candidate hospitals evaluated on clinical fit,
/// road travel time, data freshness, and emergency room load.
class HospitalDiscoveryScreen extends ConsumerStatefulWidget {
  const HospitalDiscoveryScreen({super.key});

  @override
  ConsumerState<HospitalDiscoveryScreen> createState() =>
      _HospitalDiscoveryScreenState();
}

class _HospitalDiscoveryScreenState extends ConsumerState<HospitalDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    // Search is ready by default from matchingProvider.initial()
  }

  void _handleRequestHold(HospitalMatch hospital) {
    ref.read(selectedHospitalProvider.notifier).selectHospital(hospital);
    context.go('/ambulance/hold');
  }

  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingProvider);
    final matchingNotifier = ref.read(matchingProvider.notifier);

    return AppScaffold(
      title: 'HOSPITAL MATCHES',
      subtitle: 'Step 3 of 5 • Multi-Criteria Ranking',
      actions: [
        IconButton(
          tooltip: 'Refresh Search',
          icon: const Icon(Icons.refresh_rounded, color: AppColors.secondaryTeal),
          onPressed: matchingState.isSearching
              ? null
              : () => matchingNotifier.runSearchProgression(),
        ),
      ],
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 6.2 Patient Requirement Summary Bar
              PatientRequirementSummaryBar(
                onEditRequirements: () => context.go('/ambulance/requirements'),
              ),
              const SizedBox(height: 12),

              // 6.1 Searching / Progress State
              if (matchingState.isSearching) ...[
                MatchingSearchIndicator(
                  radiusKm: matchingState.searchRadiusKm,
                  statusMessage: matchingState.searchingProgressMessage,
                  candidateCount: matchingState.matches.length,
                ),
                const SizedBox(height: 16),
              ],

              // Fixture & Filter Switcher Bar (Demo & Verification)
              _buildFilterAndFixtureBar(matchingState, matchingNotifier),
              const SizedBox(height: 12),

              // Content: Results or Empty State
              if (matchingState.matches.isEmpty)
                _buildEmptyState(matchingNotifier)
              else ...[
                // Section Header: Top Match
                const Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'PRIMARY RECOMMENDATION',
                      style: AppTypography.operationalLabel,
                    ),
                    BedLinkBadge(
                      label: 'FASTEST ROAD ROUTE',
                      backgroundColor: AppColors.tealSurface,
                      textColor: AppColors.tealDark,
                      borderColor: AppColors.tealBorder,
                      isMonospaced: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 6.3 & 6.4 Primary Featured Card (Rank #1)
                if (matchingState.primaryMatch != null)
                  PrimaryHospitalCard(
                    hospital: matchingState.primaryMatch!,
                    onRequestHold: () =>
                        _handleRequestHold(matchingState.primaryMatch!),
                  ),
                const SizedBox(height: 18),

                // 6.7 Secondary Candidates List
                if (matchingState.secondaryMatches.isNotEmpty) ...[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'ALTERNATIVE CANDIDATES (${matchingState.secondaryMatches.length})',
                        style: AppTypography.operationalLabel,
                      ),
                      const BedLinkBadge(
                        label: 'RANKED BY ETA & CAPACITY',
                        isMonospaced: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  for (final candidate in matchingState.secondaryMatches) ...[
                    HospitalMatchTile(
                      hospital: candidate,
                      isDivertRisk: candidate.recommendationTier.isDivertRisk,
                      isIncompatible:
                          candidate.recommendationTier.isIncompatible,
                      onRequestHold: () => _handleRequestHold(candidate),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ],

              const SizedBox(height: 16),

              // Navigation Actions
              BedLinkButton(
                label: 'BACK TO REQUIREMENTS',
                icon: Icons.arrow_back_rounded,
                variant: BedLinkButtonVariant.secondary,
                onPressed: () => context.go('/ambulance/requirements'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterAndFixtureBar(
    MatchingState state,
    MatchingNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 6,
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'DISCOVERY FIXTURES',
            style: AppTypography.caption,
          ),
          // Fixture selector (5 matches, 1 match, 0 matches)
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _FixtureChip(
                label: '5 Matches',
                isSelected: state.fixtureMode == MatchingFixtureMode.standardFive,
                onTap: () =>
                    notifier.setFixtureMode(MatchingFixtureMode.standardFive),
              ),
              _FixtureChip(
                label: '1 Match',
                isSelected: state.fixtureMode == MatchingFixtureMode.singleMatch,
                onTap: () =>
                    notifier.setFixtureMode(MatchingFixtureMode.singleMatch),
              ),
              _FixtureChip(
                label: '0 Matches',
                isSelected: state.fixtureMode == MatchingFixtureMode.noMatches,
                onTap: () =>
                    notifier.setFixtureMode(MatchingFixtureMode.noMatches),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(MatchingNotifier notifier) {
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
            'NO COMPATIBLE HOSPITALS FOUND',
            style: AppTypography.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'No hospitals with available ICU beds or requested capabilities were located within the current 15 km search radius.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          BedLinkButton(
            label: 'EXPAND SEARCH RADIUS TO 30 KM',
            icon: Icons.zoom_out_map_rounded,
            variant: BedLinkButtonVariant.available,
            onPressed: () {
              notifier.setFixtureMode(MatchingFixtureMode.standardFive);
              notifier.expandRadius(30);
            },
          ),
          const SizedBox(height: 8),
          BedLinkButton(
            label: 'RELAX REQUIREMENTS',
            icon: Icons.tune_rounded,
            variant: BedLinkButtonVariant.secondary,
            onPressed: () => context.go('/ambulance/requirements'),
          ),
        ],
      ),
    );
  }
}

class _FixtureChip extends StatelessWidget {
  const _FixtureChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tealSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.secondaryTeal : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.tealDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
