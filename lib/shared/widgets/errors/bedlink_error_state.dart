import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/bedlink_button.dart';
import '../cards/bedlink_card.dart';

/// Standardized high-contrast Error & Failure State component for BedLink.
class BedLinkErrorState extends StatelessWidget {
  const BedLinkErrorState({
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.isCritical = false,
    this.isCard = true,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final bool isCritical;
  final bool isCard;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final iconColor = isCritical ? AppColors.criticalRed : AppColors.warningDark;
    final iconBgColor = isCritical ? AppColors.criticalSurface : AppColors.warningSurface;
    final iconBorderColor = isCritical ? AppColors.criticalBorder : AppColors.warningBorder;

    final content = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: iconBorderColor, width: 1.5),
            ),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: 18),
            BedLinkButton(
              label: primaryActionLabel!,
              icon: primaryActionIcon,
              variant: isCritical
                  ? BedLinkButtonVariant.critical
                  : BedLinkButtonVariant.primary,
              isFullWidth: false,
              onPressed: onPrimaryAction,
            ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 10),
            BedLinkButton(
              label: secondaryActionLabel!,
              icon: secondaryActionIcon,
              variant: BedLinkButtonVariant.secondary,
              isFullWidth: false,
              onPressed: onSecondaryAction,
            ),
          ],
        ],
      ),
    );

    if (isCard) {
      return BedLinkCard(
        variant: isCritical ? BedLinkCardVariant.critical : BedLinkCardVariant.warning,
        padding: EdgeInsets.zero,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
