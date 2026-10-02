import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Active clinical requirement chip with optional quantity badge and remove trigger.
class BedLinkRequirementChip extends StatelessWidget {
  const BedLinkRequirementChip({
    required this.label,
    required this.onRemove,
    this.quantity,
    this.isCountable = true,
    super.key,
  });

  final String label;
  final VoidCallback onRemove;
  final int? quantity;
  final bool isCountable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primarySlate, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCountable && quantity != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primarySlate,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${quantity}x',
                style: AppTypography.operationalValueSm.copyWith(
                  color: AppColors.textInverse,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.labelStrong.copyWith(fontSize: 13),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shortcut chip for quickly adding common clinical resources.
class BedLinkQuickAddChip extends StatelessWidget {
  const BedLinkQuickAddChip({
    required this.label,
    required this.onTap,
    this.icon,
    this.isAdded = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool isAdded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAdded ? AppColors.tealSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isAdded ? AppColors.secondaryTeal : AppColors.border,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isAdded ? Icons.check_rounded : (icon ?? Icons.add_rounded),
                size: 15,
                color: isAdded ? AppColors.tealDark : AppColors.secondaryTeal,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isAdded ? AppColors.tealDark : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Generic removable chip.
class BedLinkRemovableChip extends StatelessWidget {
  const BedLinkRemovableChip({
    required this.label,
    required this.onDeleted,
    this.backgroundColor,
    super.key,
  });

  final String label;
  final VoidCallback onDeleted;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTypography.bodySmall),
      backgroundColor: backgroundColor ?? AppColors.surfaceSubtle,
      side: const BorderSide(color: AppColors.border),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onDeleted,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}
