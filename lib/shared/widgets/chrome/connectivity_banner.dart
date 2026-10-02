import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/connectivity_provider.dart';

/// High-visibility clinical banner displayed whenever the client is offline or reconnecting.
/// Communicates that offline cache is active and preserves existing patient/triage workflow.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityProvider);
    final notifier = ref.read(connectivityProvider.notifier);

    if (status.isOnline) {
      return const SizedBox.shrink();
    }

    final isOffline = status.isOffline;
    final bgColor = isOffline ? AppColors.warningSurface : AppColors.infoSurface;
    final borderColor = isOffline ? AppColors.warningBorder : AppColors.infoBorder;
    final textColor = isOffline ? AppColors.warningDark : AppColors.infoDark;
    final icon = isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOffline
                      ? 'OFFLINE MODE • CACHED DATA ACTIVE'
                      : 'RECONNECTING TO MED-NET...',
                  style: AppTypography.operationalLabel.copyWith(
                    color: textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isOffline
                      ? 'Showing last-known census. Local emergency workflows remain active.'
                      : 'Re-establishing encrypted medical data link and updating state...',
                  style: AppTypography.caption.copyWith(
                    color: textColor,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              if (isOffline) {
                notifier.setReconnecting();
              } else {
                notifier.setOnline();
              }
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                isOffline ? 'RECONNECT' : 'RESTORE',
                style: AppTypography.caption.copyWith(
                  color: textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
