import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum ValidationSeverity {
  error,
  warning,
  info,
}

/// Inline validation or safety message banner.
class BedLinkValidationMessage extends StatelessWidget {
  const BedLinkValidationMessage({
    required this.message,
    this.severity = ValidationSeverity.error,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final ValidationSeverity severity;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;

    switch (severity) {
      case ValidationSeverity.error:
        backgroundColor = AppColors.criticalSurface;
        borderColor = AppColors.criticalBorder;
        textColor = AppColors.criticalDark;
        icon = Icons.error_outline_rounded;
        break;
      case ValidationSeverity.warning:
        backgroundColor = AppColors.warningSurface;
        borderColor = AppColors.warningBorder;
        textColor = AppColors.warningDark;
        icon = Icons.warning_amber_rounded;
        break;
      case ValidationSeverity.info:
        backgroundColor = AppColors.infoSurface;
        borderColor = AppColors.infoBorder;
        textColor = AppColors.infoDark;
        icon = Icons.info_outline_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: AppTypography.operationalLabel.copyWith(
                  color: textColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
