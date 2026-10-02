import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../cards/bedlink_card.dart';

/// Clinical-grade operational loading indicator for async simulation and future backend queries.
class BedLinkLoadingIndicator extends StatelessWidget {
  const BedLinkLoadingIndicator({
    this.statusText = 'PROCESSING EMERGENCY OPERATION...',
    this.subtitle,
    this.isCard = false,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final String statusText;
  final String? subtitle;
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
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryTeal),
              backgroundColor: AppColors.tealSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: AppTypography.operationalLabel.copyWith(
              color: AppColors.primarySlate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
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
