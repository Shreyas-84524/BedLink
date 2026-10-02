import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';

/// Animated radar pulse and radius progression indicator during discovery search.
class MatchingSearchIndicator extends StatefulWidget {
  const MatchingSearchIndicator({
    required this.radiusKm,
    required this.statusMessage,
    this.candidateCount = 0,
    super.key,
  });

  final int radiusKm;
  final String statusMessage;
  final int candidateCount;

  @override
  State<MatchingSearchIndicator> createState() => _MatchingSearchIndicatorState();
}

class _MatchingSearchIndicatorState extends State<MatchingSearchIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Radar Pulse Graphic
          SizedBox(
            width: 96,
            height: 96,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPulsePainter(
                    progress: _pulseController.value,
                    color: AppColors.secondaryTeal,
                  ),
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryTeal,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.radar,
                        color: AppColors.secondaryTeal,
                        size: 24,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Operational Status Text
          const Text(
            'SEARCHING NEARBY HOSPITALS',
            style: AppTypography.operationalLabel,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            widget.statusMessage,
            style: AppTypography.cardTitle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Radius & Speed Indicators
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              BedLinkBadge(
                label: '${widget.radiusKm} KM RADIUS',
                backgroundColor: AppColors.tealSurface,
                textColor: AppColors.tealDark,
                borderColor: AppColors.tealBorder,
                icon: Icons.adjust_rounded,
                isMonospaced: true,
              ),
              const BedLinkBadge(
                label: 'ORS ROAD MATRIX ACTIVE',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textSecondary,
                borderColor: AppColors.border,
                icon: Icons.alt_route_rounded,
              ),
              if (widget.candidateCount > 0)
                BedLinkBadge(
                  label: '${widget.candidateCount} CANDIDATES FOUND',
                  backgroundColor: AppColors.surfaceSubtle,
                  textColor: AppColors.tealDark,
                  borderColor: AppColors.tealBorder,
                  icon: Icons.check_circle_outline_rounded,
                  isMonospaced: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RadarPulsePainter extends CustomPainter {
  const _RadarPulsePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Static concentric guide rings
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, maxRadius * 0.45, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.75, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.98, ringPaint);

    // Animated expanding pulse wave 1
    final waveRadius1 = (progress * maxRadius).clamp(0.0, maxRadius);
    final waveAlpha1 = (1.0 - progress).clamp(0.0, 1.0) * 0.45;
    final wavePaint1 = Paint()
      ..color = color.withValues(alpha: waveAlpha1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(center, waveRadius1, wavePaint1);

    // Animated expanding pulse wave 2 (offset)
    final progress2 = (progress + 0.5) % 1.0;
    final waveRadius2 = (progress2 * maxRadius).clamp(0.0, maxRadius);
    final waveAlpha2 = (1.0 - progress2).clamp(0.0, 1.0) * 0.35;
    final wavePaint2 = Paint()
      ..color = color.withValues(alpha: waveAlpha2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, waveRadius2, wavePaint2);

    // Rotating sweep line
    final angle = progress * 2 * math.pi;
    final sweepEnd = Offset(
      center.dx + maxRadius * math.cos(angle),
      center.dy + maxRadius * math.sin(angle),
    );
    final sweepPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    canvas.drawLine(center, sweepEnd, sweepPaint);
  }

  @override
  bool shouldRepaint(_RadarPulsePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
