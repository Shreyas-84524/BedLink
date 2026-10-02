import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/hold_timer_provider.dart';

/// Development & demonstration fixture controls for testing 2-minute hold states without waiting.
class MockOfferControllerBar extends StatelessWidget {
  const MockOfferControllerBar({
    required this.notifier,
    super.key,
  });

  final HoldTimerNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'DEMO SIMULATION CONTROLS',
            style: AppTypography.caption,
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              _SimButton(
                label: 'Reset 120s',
                onTap: () => notifier.startHold(),
              ),
              _SimButton(
                label: 'Accept & Lock',
                color: AppColors.tealSurface,
                textColor: AppColors.tealDark,
                borderColor: AppColors.secondaryTeal,
                onTap: () => notifier.simulateAccept(),
              ),
              _SimButton(
                label: 'Reject Offer',
                color: AppColors.criticalSurface,
                textColor: AppColors.criticalDark,
                borderColor: AppColors.criticalBorder,
                onTap: () => notifier.simulateReject(
                  reason: 'Emergency Department at maximum surge capacity',
                ),
              ),
              _SimButton(
                label: 'Simulate 00:00',
                color: AppColors.warningSurface,
                textColor: AppColors.warningDark,
                borderColor: AppColors.warningBorder,
                onTap: () => notifier.simulateTimeout(),
              ),
              _SimButton(
                label: '30s Warning',
                onTap: () => notifier.setRemainingSeconds(30),
              ),
              _SimButton(
                label: '10s Critical',
                onTap: () => notifier.setRemainingSeconds(10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimButton extends StatelessWidget {
  const _SimButton({
    required this.label,
    required this.onTap,
    this.color = AppColors.surface,
    this.textColor = AppColors.textPrimary,
    this.borderColor = AppColors.border,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
