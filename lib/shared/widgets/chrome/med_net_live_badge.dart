import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Live Operational Status Badge ("MED-NET LIVE").
class MedNetLiveBadge extends StatelessWidget {
  const MedNetLiveBadge({
    this.isLive = true,
    this.customLabel,
    super.key,
  });

  final bool isLive;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isLive ? AppColors.tealSurface : AppColors.surfaceSubtle;
    final Color textColor = isLive ? AppColors.tealDark : AppColors.textSecondary;
    final Color dotColor = isLive ? AppColors.secondaryTeal : AppColors.textMuted;
    final Color borderColor = isLive ? AppColors.tealBorder : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            customLabel ?? (isLive ? 'MED-NET LIVE' : 'OFFLINE'),
            style: AppTypography.operationalLabel.copyWith(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
