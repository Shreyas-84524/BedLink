import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../buttons/bedlink_button.dart';
import '../cards/bedlink_card.dart';

/// Reusable high-contrast empty state for data collections and uninitialized workflows.
class BedLinkEmptyState extends StatelessWidget {
  const BedLinkEmptyState({
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.actionVariant = BedLinkButtonVariant.primary,
    this.isCard = true,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final BedLinkButtonVariant actionVariant;
  final bool isCard;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
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
              color: AppColors.surfaceSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(
              icon,
              size: 28,
              color: AppColors.textSecondary,
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
            description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            BedLinkButton(
              label: actionLabel!,
              icon: actionIcon,
              variant: actionVariant,
              isFullWidth: false,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );

    if (isCard) {
      return BedLinkCard(
        variant: BedLinkCardVariant.muted,
        padding: EdgeInsets.zero,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
