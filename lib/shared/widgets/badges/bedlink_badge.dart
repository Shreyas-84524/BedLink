import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/semantic_tokens.dart';

/// Base BedLink high-contrast badge component.
class BedLinkBadge extends StatelessWidget {
  const BedLinkBadge({
    required this.label,
    this.backgroundColor = AppColors.surfaceSubtle,
    this.textColor = AppColors.textPrimary,
    this.borderColor = AppColors.border,
    this.icon,
    this.isMonospaced = false,
    super.key,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;
  final bool isMonospaced;

  factory BedLinkBadge.fromSemantic({
    required String label,
    required SemanticBadgeColors colors,
    IconData? icon,
    bool isMonospaced = false,
    Key? key,
  }) {
    return BedLinkBadge(
      key: key,
      label: label,
      backgroundColor: colors.background,
      textColor: colors.text,
      borderColor: colors.border,
      icon: icon ?? Icons.circle,
      isMonospaced: isMonospaced,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 8,
              color: textColor,
            ),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: (isMonospaced ? AppTypography.operationalValueSm : AppTypography.badge)
                  .copyWith(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
