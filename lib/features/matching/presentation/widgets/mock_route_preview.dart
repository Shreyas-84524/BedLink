import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import '../../domain/models/hospital_match.dart';

/// Lightweight vector route preview container showing road corridor and destination pin.
class MockRoutePreview extends StatelessWidget {
  const MockRoutePreview({
    required this.hospital,
    this.compact = false,
    super.key,
  });

  final HospitalMatch hospital;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar: Live corridor & matrix indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.navigation_rounded,
                      size: 13,
                      color: AppColors.secondaryTeal,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'ORS ROUTE PREVIEW',
                        style: AppTypography.operationalLabel.copyWith(
                          color: AppColors.secondaryTeal,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              BedLinkBadge(
                label: '${hospital.etaDisplayText} • ${hospital.distanceDisplayText}',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textPrimary,
                borderColor: AppColors.border,
                isMonospaced: true,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Visual Vector Route Canvas
          SizedBox(
            height: compact ? 64 : 84,
            child: CustomPaint(
              painter: const _VectorRoutePainter(
                routeColor: AppColors.secondaryTeal,
                gridColor: AppColors.borderSubtle,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Origin: Ambulance
                    SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: AppColors.secondaryTeal,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.emergency_rounded,
                              size: 14,
                              color: AppColors.secondaryTeal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'AMB',
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Intermediate Road Segment Tag
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          hospital.routeSummary,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    // Destination: Hospital
                    SizedBox(
                      width: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.tealSurface,
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(
                                BorderSide(
                                  color: AppColors.tealBorder,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              size: 14,
                              color: AppColors.tealDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            hospital.area.split(',').first.trim(),
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.tealDark,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VectorRoutePainter extends CustomPainter {
  const _VectorRoutePainter({
    required this.routeColor,
    required this.gridColor,
  });

  final Color routeColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle grid background lines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.8;

    for (double y = 10; y < size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bezier connecting route curve
    final start = Offset(36, size.height / 2);
    final end = Offset(size.width - 36, size.height / 2);
    final control1 = Offset(size.width * 0.35, size.height * 0.2);
    final control2 = Offset(size.width * 0.65, size.height * 0.8);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        end.dx,
        end.dy,
      );

    // Outer glow path
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawPath(path, glowPaint);

    // Primary route path
    final routePaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(_VectorRoutePainter oldDelegate) => false;
}
