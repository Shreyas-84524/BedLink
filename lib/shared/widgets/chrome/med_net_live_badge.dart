import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/connectivity_provider.dart';

/// Live Operational Status Badge ("MED-NET LIVE" / "OFFLINE" / "RECONNECTING").
class MedNetLiveBadge extends ConsumerWidget {
  const MedNetLiveBadge({
    this.isLive,
    this.customLabel,
    this.enableTapToggle = true,
    super.key,
  });

  final bool? isLive;
  final String? customLabel;
  final bool enableTapToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final notifier = ref.read(connectivityProvider.notifier);

    final effectiveLive = isLive ?? connectivity.isOnline;
    final String label = customLabel ?? (isLive != null
        ? (isLive! ? 'MED-NET LIVE' : 'OFFLINE')
        : connectivity.label);

    Color bgColor;
    Color textColor;
    Color dotColor;
    Color borderColor;

    if (customLabel != null || isLive != null) {
      bgColor = effectiveLive ? AppColors.tealSurface : AppColors.surfaceSubtle;
      textColor = effectiveLive ? AppColors.tealDark : AppColors.textSecondary;
      dotColor = effectiveLive ? AppColors.secondaryTeal : AppColors.textMuted;
      borderColor = effectiveLive ? AppColors.tealBorder : AppColors.border;
    } else {
      bgColor = connectivity.backgroundColor;
      textColor = connectivity.indicatorColor;
      dotColor = connectivity.indicatorColor;
      borderColor = connectivity.borderColor;
    }

    final badge = Container(
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
            label,
            style: AppTypography.operationalLabel.copyWith(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    if (enableTapToggle && isLive == null) {
      return InkWell(
        onTap: () => notifier.cycleNextState(),
        borderRadius: BorderRadius.circular(4),
        child: badge,
      );
    }

    return badge;
  }
}
