import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/hold_status.dart';

/// Circular 120-second countdown timer for the BedLink 2-minute emergency hold protocol.
///
/// NOTE: In Phase 7, this countdown operates purely locally for demonstration.
/// In Phase 12, authoritative timer expiration will be governed by server `expires_at`.
class CircularHoldCountdown extends StatelessWidget {
  const CircularHoldCountdown({
    required this.remainingSeconds,
    required this.status,
    this.diameter = 160.0,
    super.key,
  });

  /// Seconds remaining in the 120s window (120..0).
  final int remainingSeconds;

  /// Current hold lifecycle state.
  final HoldLifecycleState status;

  /// Diameter of the circular countdown widget.
  final double diameter;

  Color get _ringColor {
    if (status.isAccepted) return AppColors.secondaryTeal;
    if (status.isRejected || status.isTimedOut) return AppColors.criticalRed;
    if (remainingSeconds <= 10) return AppColors.criticalRed;
    if (remainingSeconds <= 30) return AppColors.warningAmber;
    return AppColors.secondaryTeal;
  }

  String get _timeDisplay {
    if (status.isAccepted) return 'LOCKED';
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _statusSubtitle {
    if (status.isAccepted) return 'BED LOCKED';
    if (status.isRejected) return 'OFFER DECLINED';
    if (status.isTimedOut) return 'HOLD EXPIRED';
    if (remainingSeconds <= 10) return 'EXPIRING IMMINENTLY';
    if (remainingSeconds <= 30) return 'APPROACHING TIMEOUT';
    return '2-MIN WINDOW';
  }

  @override
  Widget build(BuildContext context) {
    final progress = status.isAccepted
        ? 1.0
        : (remainingSeconds / 120.0).clamp(0.0, 1.0);
    final ringColor = _ringColor;

    return Center(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: CustomPaint(
          painter: _CircularCountdownPainter(
            progress: progress,
            ringColor: ringColor,
            trackColor: AppColors.surfaceSubtle,
            strokeWidth: 9.0,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  status.isAccepted
                      ? Icons.lock_rounded
                      : status.isRejected
                          ? Icons.cancel_outlined
                          : status.isTimedOut
                              ? Icons.timer_off_outlined
                              : Icons.timer_outlined,
                  size: 20,
                  color: ringColor,
                ),
                const SizedBox(height: 4),
                Text(
                  _timeDisplay,
                  style: (status.isAccepted
                          ? AppTypography.cardTitle
                          : AppTypography.operationalValueLg)
                      .copyWith(
                    color: ringColor,
                    fontSize: status.isAccepted ? 20 : 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusSubtitle,
                  style: AppTypography.operationalLabel.copyWith(
                    color: ringColor.withValues(alpha: 0.9),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularCountdownPainter extends CustomPainter {
  const _CircularCountdownPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track ring
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress sweep arc starting at top (-pi/2)
      final sweepAngle = 2 * math.pi * progress;
      final arcPaint = Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularCountdownPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
