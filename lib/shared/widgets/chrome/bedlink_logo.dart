import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Clinical Brand Identity Logo for BedLink.
class BedLinkLogo extends StatelessWidget {
  const BedLinkLogo({
    this.compact = false,
    this.showTagline = false,
    super.key,
  });

  final bool compact;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primarySlate,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              size: 16,
              color: AppColors.secondaryTeal,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primarySlate,
              letterSpacing: -0.5,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySlate,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            size: 20,
            color: AppColors.secondaryTeal,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primarySlate,
                height: 1.1,
                letterSpacing: -0.5,
              ),
            ),
            if (showTagline)
              Text(
                'EMERGENCY DISPATCH',
                style: AppTypography.operationalLabel.copyWith(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
