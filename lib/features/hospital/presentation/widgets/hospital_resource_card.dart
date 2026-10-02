import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../../../shared/widgets/cards/bedlink_card.dart';
import '../../../../shared/widgets/inputs/bedlink_counter_control.dart';
import '../../domain/models/hospital_resource_item.dart';
import '../providers/hospital_state_provider.dart';

/// Card displaying capacity, utilization progress, and instant availability controls for a hospital resource.
class HospitalResourceCard extends ConsumerWidget {
  const HospitalResourceCard({
    required this.resource,
    super.key,
  });

  final HospitalResourceItem resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!resource.isCountable) {
      return _buildCapabilityCard(context);
    }

    final occupancyPercent = (resource.occupancyRate * 100).toInt();

    return BedLinkCard(
      variant: resource.available == 0
          ? BedLinkCardVariant.critical
          : resource.available <= 2
              ? BedLinkCardVariant.warning
              : BedLinkCardVariant.defaultCard,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resource Title & Availability Summary
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.name.toUpperCase(),
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TOTAL CAPACITY: ${resource.total} BEDS',
                      style: AppTypography.operationalLabel.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              BedLinkBadge(
                label: '$occupancyPercent% OCCUPIED',
                backgroundColor: occupancyPercent >= 90
                    ? AppColors.criticalSurface
                    : occupancyPercent >= 70
                        ? AppColors.warningSurface
                        : AppColors.surfaceSubtle,
                textColor: occupancyPercent >= 90
                    ? AppColors.criticalRed
                    : occupancyPercent >= 70
                        ? AppColors.warningDark
                        : AppColors.textPrimary,
                borderColor: occupancyPercent >= 90
                    ? AppColors.criticalBorder
                    : occupancyPercent >= 70
                        ? AppColors.warningBorder
                        : AppColors.border,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Occupancy Breakdown Meter Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  if (resource.occupied > 0)
                    Expanded(
                      flex: resource.occupied,
                      child: Container(color: AppColors.primarySlate),
                    ),
                  if (resource.held > 0)
                    Expanded(
                      flex: resource.held,
                      child: Container(color: AppColors.warningAmber),
                    ),
                  if (resource.available > 0)
                    Expanded(
                      flex: resource.available,
                      child: Container(color: AppColors.secondaryTeal),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Bed Breakdown Counts
          Wrap(
            spacing: 10,
            runSpacing: 4,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildCountTag(
                label: 'OCCUPIED',
                count: resource.occupied,
                color: AppColors.primarySlate,
              ),
              _buildCountTag(
                label: 'HELD',
                count: resource.held,
                color: AppColors.warningAmber,
              ),
              _buildCountTag(
                label: 'AVAILABLE',
                count: resource.available,
                color: AppColors.secondaryTeal,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Rapid Stepper Control (Sub-10s updates)
          BedLinkCounterControl(
            label: 'ADJUST AVAILABLE BEDS (INSTANT)',
            value: resource.available,
            unit: 'AVAILABLE',
            min: 0,
            max: resource.total - resource.occupied - resource.held,
            onChanged: (newVal) {
              if (newVal > resource.available) {
                ref.read(hospitalStateProvider.notifier).incrementResource(resource.id);
              } else if (newVal < resource.available) {
                ref.read(hospitalStateProvider.notifier).decrementResource(resource.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityCard(BuildContext context) {
    return BedLinkCard(
      variant: resource.isOperational
          ? BedLinkCardVariant.defaultCard
          : BedLinkCardVariant.muted,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: resource.isOperational
                  ? AppColors.tealSurface
                  : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: resource.isOperational
                    ? AppColors.tealBorder
                    : AppColors.border,
              ),
            ),
            child: Icon(
              resource.isOperational ? Icons.check_circle_outline_rounded : Icons.block_rounded,
              color: resource.isOperational ? AppColors.secondaryTeal : AppColors.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  resource.category.toUpperCase(),
                  style: AppTypography.operationalLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          BedLinkBadge(
            label: resource.isOperational ? 'OPERATIONAL' : 'OFFLINE',
            backgroundColor: resource.isOperational ? AppColors.tealSurface : AppColors.surfaceSubtle,
            textColor: resource.isOperational ? AppColors.tealDark : AppColors.textMuted,
            borderColor: resource.isOperational ? AppColors.tealBorder : AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildCountTag({
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: $count',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
