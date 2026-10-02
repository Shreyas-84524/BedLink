import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum BedLinkCardVariant {
  defaultCard,
  muted,
  highlighted,
  recommended,
  critical,
  warning,
  info,
}

/// Standardized high-contrast Clinical Surface / Card adhering to design.md.
class BedLinkCard extends StatelessWidget {
  const BedLinkCard({
    required this.child,
    this.variant = BedLinkCardVariant.defaultCard,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    super.key,
  });

  final Widget child;
  final BedLinkCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = AppColors.surface;
    Color borderColor = AppColors.border;
    double borderWidth = 1.0;
    Color? leftAccentColor;

    switch (variant) {
      case BedLinkCardVariant.defaultCard:
        backgroundColor = AppColors.surface;
        borderColor = AppColors.border;
        borderWidth = 1.0;
        break;
      case BedLinkCardVariant.muted:
        backgroundColor = AppColors.surfaceSubtle;
        borderColor = AppColors.borderSubtle;
        borderWidth = 1.0;
        break;
      case BedLinkCardVariant.highlighted:
        backgroundColor = AppColors.surface;
        borderColor = AppColors.borderActive;
        borderWidth = 2.0;
        break;
      case BedLinkCardVariant.recommended:
        backgroundColor = AppColors.surface;
        borderColor = AppColors.secondaryTeal;
        borderWidth = 2.0;
        break;
      case BedLinkCardVariant.critical:
        backgroundColor = AppColors.surface;
        borderColor = AppColors.borderSubtle;
        borderWidth = 1.0;
        leftAccentColor = AppColors.criticalRed;
        break;
      case BedLinkCardVariant.warning:
        backgroundColor = AppColors.surface;
        borderColor = AppColors.borderSubtle;
        borderWidth = 1.0;
        leftAccentColor = AppColors.warningAmber;
        break;
      case BedLinkCardVariant.info:
        backgroundColor = AppColors.infoSurface;
        borderColor = AppColors.infoBorder;
        borderWidth = 1.0;
        break;
    }

    final cardContent = Container(
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leftAccentColor != null)
              Container(
                width: 4.0,
                color: leftAccentColor,
              ),
            Expanded(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
