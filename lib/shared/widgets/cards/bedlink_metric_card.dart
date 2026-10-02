import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'bedlink_card.dart';

/// Card for structured tabular metric displays (e.g. ETA, Bed Capacity, Freshness).
class BedLinkMetricCard extends StatelessWidget {
  const BedLinkMetricCard({
    required this.label,
    required this.value,
    this.unit,
    this.subtext,
    this.icon,
    this.variant = BedLinkCardVariant.defaultCard,
    this.valueColor,
    this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final String? unit;
  final String? subtext;
  final IconData? icon;
  final BedLinkCardVariant variant;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BedLinkCard(
      variant: variant,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AppTypography.operationalLabel.copyWith(fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.operationalValue.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    unit!,
                    style: AppTypography.operationalValueSm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 4),
            Text(
              subtext!,
              style: AppTypography.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
