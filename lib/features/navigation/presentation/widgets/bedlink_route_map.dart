import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../../core/config/map_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/badges/bedlink_badge.dart';
import 'mock_route_map.dart';

/// Combined MapLibre vector map and fallback tactical route map widget.
///
/// When MapTiler is configured and enabled, renders a high-performance vector basemap
/// using MapLibre GL with real ambulance and hospital marker pins and ORS route polyline.
/// When unconfigured, in test mode, or upon loading error, safely falls back
/// to the tactical vector canvas [MockRouteMap].
class BedlinkRouteMap extends ConsumerStatefulWidget {
  const BedlinkRouteMap({
    required this.routeProgress,
    required this.destinationName,
    this.ambulanceLatitude,
    this.ambulanceLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.routeGeometry = const [],
    this.isRealRouting = false,
    super.key,
  });

  final double routeProgress;
  final String destinationName;
  final double? ambulanceLatitude;
  final double? ambulanceLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final List<({double latitude, double longitude})> routeGeometry;
  final bool isRealRouting;

  @override
  ConsumerState<BedlinkRouteMap> createState() => _BedlinkRouteMapState();
}

class _BedlinkRouteMapState extends ConsumerState<BedlinkRouteMap> {
  MapLibreMapController? _mapController;
  bool _mapStyleLoaded = false;
  bool _hasMapError = false;

  @override
  void didUpdateWidget(covariant BedlinkRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapStyleLoaded && _mapController != null) {
      if (oldWidget.routeProgress != widget.routeProgress ||
          oldWidget.routeGeometry != widget.routeGeometry) {
        _updateMapLayers();
      }
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    try {
      _mapController = controller;
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasMapError = true;
        });
      }
    }
  }

  void _onStyleLoaded() {
    try {
      if (mounted) {
        setState(() {
          _mapStyleLoaded = true;
        });
      }
      _updateMapLayers();
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasMapError = true;
        });
      }
    }
  }

  Future<void> _updateMapLayers() async {
    final controller = _mapController;
    if (controller == null || !_mapStyleLoaded) return;

    try {
      // Clear previous annotations
      await controller.clearCircles();
      await controller.clearLines();

      final ambLat = widget.ambulanceLatitude;
      final ambLng = widget.ambulanceLongitude;
      final destLat = widget.destinationLatitude;
      final destLng = widget.destinationLongitude;

      // 1. Draw route polyline if available
      if (widget.routeGeometry.isNotEmpty) {
        final linePoints = widget.routeGeometry
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        await controller.addLine(
          LineOptions(
            geometry: linePoints,
            lineColor: '#0D9488', // AppColors.secondaryTeal
            lineWidth: 5.0,
            lineOpacity: 0.9,
          ),
        );
      } else if (ambLat != null && ambLng != null && destLat != null && destLng != null) {
        // Direct corridor connecting ambulance and destination
        await controller.addLine(
          LineOptions(
            geometry: [
              LatLng(ambLat, ambLng),
              LatLng(destLat, destLng),
            ],
            lineColor: '#0D9488',
            lineWidth: 4.0,
            lineOpacity: 0.7,
          ),
        );
      }

      // 2. Add destination hospital marker pin
      if (destLat != null && destLng != null) {
        await controller.addCircle(
          CircleOptions(
            geometry: LatLng(destLat, destLng),
            circleColor: '#EF4444', // AppColors.criticalRed
            circleRadius: 10.0,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2.5,
            circleOpacity: 1.0,
          ),
        );
      }

      // 3. Add ambulance marker pin
      if (ambLat != null && ambLng != null) {
        await controller.addCircle(
          CircleOptions(
            geometry: LatLng(ambLat, ambLng),
            circleColor: '#14B8A6', // AppColors.mintLive / teal
            circleRadius: 9.0,
            circleStrokeColor: '#FFFFFF',
            circleStrokeWidth: 2.0,
            circleOpacity: 1.0,
          ),
        );
      }
    } catch (e) {
      // Non-fatal error during layer update
      debugPrint('BedlinkRouteMap layer update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapConfig = ref.watch(mapConfigProvider);

    // If MapLibre is not configured, in test mode, or errored, render MockRouteMap fallback
    if (!mapConfig.canRenderMapLibre || _hasMapError) {
      return MockRouteMap(
        routeProgress: widget.routeProgress,
        destinationName: widget.destinationName,
      );
    }

    // Determine initial camera position
    final centerLat = widget.ambulanceLatitude ?? widget.destinationLatitude ?? 18.9950;
    final centerLng = widget.ambulanceLongitude ?? widget.destinationLongitude ?? 72.8250;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
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
          // MapLibre GL Vector Map
          MapLibreMap(
            styleString: mapConfig.mapTilerStyleUrl,
            initialCameraPosition: CameraPosition(
              target: LatLng(centerLat, centerLng),
              zoom: 13.0,
            ),
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            myLocationEnabled: false,
            attributionButtonMargins: const Point(-100, -100), // Clean embedded view
          ),

          // Top Header Badge: Live MapTiler Basemap Indicator
          Positioned(
            top: 8,
            left: 8,
            child: Container(
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
                      color: AppColors.mintLive,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'MAPTILER VECTOR MAP',
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
                  BedLinkBadge(
                    label: widget.isRealRouting ? 'REAL ORS ROUTE' : 'ORS ROUTE',
                    backgroundColor: const Color(0xFF1E293B),
                    textColor: AppColors.secondaryTeal,
                    borderColor: AppColors.secondaryTeal.withValues(alpha: 0.5),
                    isMonospaced: true,
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
