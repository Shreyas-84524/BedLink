import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/semantic_tokens.dart';
import '../../../../shared/widgets/badges/status_badges.dart';
import '../../../../shared/widgets/buttons/bedlink_button.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/hospital_state_provider.dart';

/// Reusable banner showing hospital inventory freshness with one-tap "CONFIRM NO CHANGE"
/// and test fixture triggers. Responsive from 320dp to desktop widths.
class HospitalFreshnessBar extends ConsumerWidget {
  const HospitalFreshnessBar({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(hospitalStateProvider);
    final freshness = state.overallFreshnessState;
    final mins = state.minutesSinceLastConfirmed;

    final freshnessDescription = mins <= 0
        ? 'Confirmed just now'
        : mins == 1
            ? 'Confirmed 1 min ago'
            : 'Confirmed $mins mins ago';

    return BedLinkCard(
      variant: freshness == FreshnessState.fresh
          ? BedLinkCardVariant.highlighted
          : freshness == FreshnessState.aging
              ? BedLinkCardVariant.warning
              : freshness == FreshnessState.stale
                  ? BedLinkCardVariant.critical
                  : BedLinkCardVariant.defaultCard,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 10 : 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FreshnessBadge(state: freshness),
                    Text(
                      freshnessDescription.toUpperCase(),
                      style: AppTypography.operationalLabel.copyWith(
                        color: freshness == FreshnessState.fresh
                            ? AppColors.secondaryTeal
                            : freshness == FreshnessState.aging
                                ? AppColors.warningAmber
                                : AppColors.criticalRed,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Stale toggle for demo / evaluation
              InkWell(
                onTap: () {
                  if (freshness == FreshnessState.fresh) {
                    ref.read(hospitalStateProvider.notifier).simulateStaleState(minutesAgo: 35);
                  } else {
                    ref.read(hospitalStateProvider.notifier).confirmNoChange();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    freshness == FreshnessState.fresh ? 'Simulate Stale' : 'Reset Fresh',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      decoration: TextDecoration.underline,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 280) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Verify inventory status to reassure dispatchers and en-route ambulances.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BedLinkButton(
                      label: 'CONFIRM NO CHANGE',
                      icon: Icons.check_circle_outline_rounded,
                      variant: BedLinkButtonVariant.compact,
                      isFullWidth: true,
                      onPressed: () {
                        ref.read(hospitalStateProvider.notifier).confirmNoChange();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Bed inventory confirmed with no changes. Freshness updated.'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'Verify inventory status to reassure dispatchers and en-route ambulances.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  BedLinkButton(
                    label: 'CONFIRM NO CHANGE',
                    icon: Icons.check_circle_outline_rounded,
                    variant: BedLinkButtonVariant.compact,
                    isFullWidth: false,
                    onPressed: () {
                      ref.read(hospitalStateProvider.notifier).confirmNoChange();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bed inventory confirmed with no changes. Freshness updated.'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
