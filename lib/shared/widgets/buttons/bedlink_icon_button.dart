import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Accessible icon button with enforced >=48x48dp hit area, border, and tooltip.
class BedLinkIconButton extends StatelessWidget {
  const BedLinkIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.size = 20.0,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;

    final Widget button = Material(
      color: backgroundColor ?? (isEnabled ? AppColors.surface : AppColors.surfaceSubtle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: borderColor ?? (isEnabled ? AppColors.border : AppColors.disabledBorder),
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: size,
            color: color ?? (isEnabled ? AppColors.textPrimary : AppColors.disabledText),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
