import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../providers/navigation_state_provider.dart';

/// Card presenting turn-by-turn route navigation instructions, active maneuver icon,
/// step distance, and preview of upcoming turns.
class RouteInstructionCard extends ConsumerWidget {
  const RouteInstructionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationStateProvider);
    final curr = navState.currentInstruction;
    final next = navState.nextInstruction;

    return BedLinkCard(
      variant: BedLinkCardVariant.defaultCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Counter & Maneuver Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.near_me_rounded,
                      size: 16,
                      color: AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'STEP ${navState.currentInstructionIndex + 1} OF ${navState.instructions.length}',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: curr.maneuver.label,
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.primarySlate,
                borderColor: AppColors.borderStrong,
                icon: curr.maneuver.icon,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Instruction Row with High-Visibility Maneuver Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Maneuver Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySlate,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  curr.maneuver.icon,
                  size: 28,
                  color: AppColors.textInverse,
                ),
              ),
              const SizedBox(width: 12),
              // Instruction & Road Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      curr.instruction,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.alt_route_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            curr.roadName,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            curr.formattedDistance,
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primarySlate,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Overall Route Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: navState.routeProgress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Upcoming Maneuver Preview (if available)
          if (next != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Icon(
                    next.maneuver.icon,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'THEN:',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${next.instruction} (${next.formattedDistance})',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primarySlate,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.tealSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.tealBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.tealDark,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'FINAL APPROACH • PREPARE ER BAY RECEIVING PROTOCOL',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.tealDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
