import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum BedLinkButtonVariant {
  primary,
  secondary,
  critical,
  available,
  compact,
}

/// Standardized high-contrast BedLink Action Button adhering to design.md.
class BedLinkButton extends StatelessWidget {
  const BedLinkButton({
    required this.label,
    required this.onPressed,
    this.variant = BedLinkButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BedLinkButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  bool get _isEnabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final double height = variant == BedLinkButtonVariant.compact ? 38.0 : 52.0;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case BedLinkButtonVariant.primary:
        backgroundColor = _isEnabled ? AppColors.primarySlate : AppColors.disabledBackground;
        textColor = _isEnabled ? AppColors.textInverse : AppColors.disabledText;
        break;
      case BedLinkButtonVariant.secondary:
        backgroundColor = _isEnabled ? AppColors.surface : AppColors.surfaceSubtle;
        textColor = _isEnabled ? AppColors.primarySlate : AppColors.disabledText;
        borderSide = BorderSide(
          color: _isEnabled ? AppColors.borderStrong : AppColors.disabledBorder,
          width: 1.5,
        );
        break;
      case BedLinkButtonVariant.critical:
        backgroundColor = _isEnabled ? AppColors.criticalRed : AppColors.disabledBackground;
        textColor = _isEnabled ? AppColors.textInverse : AppColors.disabledText;
        break;
      case BedLinkButtonVariant.available:
        backgroundColor = _isEnabled ? AppColors.secondaryTeal : AppColors.disabledBackground;
        textColor = _isEnabled ? AppColors.textInverse : AppColors.disabledText;
        break;
      case BedLinkButtonVariant.compact:
        backgroundColor = _isEnabled ? AppColors.primarySlate : AppColors.disabledBackground;
        textColor = _isEnabled ? AppColors.textInverse : AppColors.disabledText;
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: variant == BedLinkButtonVariant.compact ? 16 : 18, color: textColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: (variant == BedLinkButtonVariant.compact
                      ? AppTypography.labelStrong
                      : AppTypography.button)
                  .copyWith(color: textColor),
            ),
          ),
        ],
      );
    }

    final buttonWidget = Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: borderSide,
      ),
      child: InkWell(
        onTap: _isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: height,
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: variant == BedLinkButtonVariant.compact ? 8 : 16,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
