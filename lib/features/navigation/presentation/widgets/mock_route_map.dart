import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';

/// Interactive high-contrast mock vector map canvas simulating live transit navigation.
/// Previews the visual layout for Phase 14 MapLibre GL vector tiles integration.
class MockRouteMap extends StatefulWidget {
  const MockRouteMap({
    required this.routeProgress,
    required this.destinationName,
    super.key,
  });

  final double routeProgress;
  final String destinationName;

  @override
  State<MockRouteMap> createState() => _MockRouteMapState();
}

class _MockRouteMapState extends State<MockRouteMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Dark slate tactical map surface
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Tactical Map Painter
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _TacticalRoutePainter(
                  progress: widget.routeProgress,
                  pulseValue: _pulseController.value,
                ),
              );
            },
          ),

          // Map Header Badge: Mock Vector Canvas Indicator
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0F172A),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryTeal,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VECTOR ROUTE MOCK',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textInverse,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Compass & GPS Lock Indicator
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xCC0F172A),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_rounded, color: AppColors.mintLive, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'N',
                    style: TextStyle(
                      color: AppColors.textInverse,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Street & Destination Tag (Bottom Left)
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xE60F172A),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderStrong.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppColors.criticalRed,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'DESTINATION: ${widget.destinationName}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const BedLinkBadge(
                    label: 'ORS ROUTE',
                    backgroundColor: Color(0xFF1E293B),
                    textColor: AppColors.mintLive,
                    borderColor: AppColors.secondaryTeal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter rendering tactical grid, arterial streets, and the active route path.
class _TacticalRoutePainter extends CustomPainter {
  const _TacticalRoutePainter({
    required this.progress,
    required this.pulseValue,
  });

  final double progress;
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Grid Lines (Mumbai urban grid approximation)
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // 2. Draw Secondary Arterial Roads
    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // East-West cross-connector
    canvas.drawLine(Offset(0, h * 0.45), Offset(w, h * 0.45), secondaryRoadPaint);
    // North-South arterial
    canvas.drawLine(Offset(w * 0.3, 0), Offset(w * 0.3, h), secondaryRoadPaint);

    // 3. Define Transit Polyline Waypoints (Lower Parel -> KEM Hospital corridor)
    final points = [
      Offset(w * 0.12, h * 0.82), // Start (Ambulance Base)
      Offset(w * 0.28, h * 0.70), // Turn 1 (Senapati Bapat Marg)
      Offset(w * 0.42, h * 0.45), // Turn 2 (Tilak Bridge)
      Offset(w * 0.65, h * 0.45), // Turn 3 (Dr. Ambedkar Rd)
      Offset(w * 0.78, h * 0.28), // Turn 4 (Acharya Donde Marg)
      Offset(w * 0.88, h * 0.20), // Destination (KEM Emergency Bay)
    ];

    // Build the complete path
    final routePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      routePath.lineTo(points[i].dx, points[i].dy);
    }

    // 4. Draw Remaining Route Path (Muted background track)
    final remainingRoutePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(routePath, remainingRoutePaint);

    // 5. Draw Active / Completed Route Path in Teal
    final clampedProgress = progress.clamp(0.01, 1.0);
    final activePath = _extractSubPath(routePath, clampedProgress);

    final activeRoutePaint = Paint()
      ..color = AppColors.mintLive
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(activePath, activeRoutePaint);

    // 6. Draw Hospital Destination Beacon at end point
    final destPoint = points.last;
    final beaconRadius = 10.0 + (pulseValue * 4.0);

    // Beacon Outer Glow
    final glowPaint = Paint()
      ..color = AppColors.criticalRed.withValues(alpha: 0.3 - (pulseValue * 0.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destPoint, beaconRadius, glowPaint);

    // Beacon Pin
    final pinPaint = Paint()
      ..color = AppColors.criticalRed
      ..style = PaintingStyle.fill;
    canvas.drawCircle(destPoint, 8, pinPaint);

    // White cross on destination pin
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(destPoint.dx - 4, destPoint.dy),
      Offset(destPoint.dx + 4, destPoint.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(destPoint.dx, destPoint.dy - 4),
      Offset(destPoint.dx, destPoint.dy + 4),
      crossPaint,
    );

    // 7. Draw Current Ambulance Position Marker
    final currentPos = _calculatePositionAlongPath(routePath, clampedProgress);

    // Pulsing Radar Ring
    final radarPaint = Paint()
      ..color = AppColors.mintLive.withValues(alpha: 0.4 * (1.0 - pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(currentPos, 14 + (pulseValue * 8), radarPaint);

    // Ambulance Marker Outer Ring
    final markerOuterPaint = Paint()
      ..color = AppColors.primarySlate
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPos, 9, markerOuterPaint);

    // Ambulance Marker Inner Dot
    final markerInnerPaint = Paint()
      ..color = AppColors.mintLive
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentPos, 6, markerInnerPaint);
  }

  Path _extractSubPath(Path source, double t) {
    final pathMetrics = source.computeMetrics();
    final result = Path();
    for (final metric in pathMetrics) {
      final extractLength = metric.length * t;
      result.addPath(metric.extractPath(0.0, extractLength), Offset.zero);
    }
    return result;
  }

  Offset _calculatePositionAlongPath(Path path, double t) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return Offset.zero;
    final metric = metrics.first;
    final length = metric.length * t;
    final tangent = metric.getTangentForOffset(length);
    return tangent?.position ?? Offset.zero;
  }

  @override
  bool shouldRepaint(covariant _TacticalRoutePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulseValue != pulseValue;
  }
}
