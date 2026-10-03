import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for MapLibre/MapTiler mapping and OpenRouteService (ORS) routing.
///
/// Values are read via compile-time `--dart-define` or `--dart-define-from-file`:
/// - `MAPTILER_API_KEY`: API key for MapTiler vector tiles & styles.
/// - `ORS_API_KEY`: API key for OpenRouteService Matrix & Directions.
@immutable
class MapConfig {
  const MapConfig({
    required this.maptilerApiKey,
    required this.orsApiKey,
    String? styleUrl,
    this.useMockMapCanvas = false,
  }) : _customStyleUrl = styleUrl;

  final String maptilerApiKey;
  final String orsApiKey;
  final String? _customStyleUrl;
  final bool useMockMapCanvas;

  /// Reads mapping configuration from compile-time environment flags.
  factory MapConfig.fromEnvironment() {
    const maptiler = String.fromEnvironment('MAPTILER_API_KEY', defaultValue: '');
    const ors = String.fromEnvironment('ORS_API_KEY', defaultValue: '');
    const forceMock = bool.fromEnvironment('FORCE_MOCK_MAP_CANVAS', defaultValue: false);

    return const MapConfig(
      maptilerApiKey: maptiler,
      orsApiKey: ors,
      useMockMapCanvas: forceMock,
    );
  }

  /// Default mock/offline configuration.
  factory MapConfig.mock({bool useMockMapCanvas = true}) {
    return MapConfig(
      maptilerApiKey: '',
      orsApiKey: '',
      useMockMapCanvas: useMockMapCanvas,
    );
  }

  /// Custom configuration for tests and local fixtures.
  factory MapConfig.custom({
    String maptilerApiKey = '',
    String orsApiKey = '',
    String? styleUrl,
    bool useMockMapCanvas = false,
  }) {
    return MapConfig(
      maptilerApiKey: maptilerApiKey,
      orsApiKey: orsApiKey,
      styleUrl: styleUrl,
      useMockMapCanvas: useMockMapCanvas,
    );
  }

  /// Whether MapTiler vector tiles are configured with a valid key.
  bool get isMapTilerConfigured => maptilerApiKey.trim().isNotEmpty;

  /// Whether OpenRouteService is configured with a valid key.
  bool get isOrsConfigured => orsApiKey.trim().isNotEmpty;

  /// Whether real vector map rendering via MapLibre is enabled.
  bool get canRenderMapLibre => isMapTilerConfigured && !useMockMapCanvas;

  /// MapTiler Style URL used by MapLibre GL.
  String get mapTilerStyleUrl {
    if (_customStyleUrl != null && _customStyleUrl.isNotEmpty) {
      return _customStyleUrl;
    }
    if (!isMapTilerConfigured) {
      return '';
    }
    return 'https://api.maptiler.com/maps/streets-v2/style.json?key=$maptilerApiKey';
  }

  @override
  String toString() {
    return 'MapConfig(maptilerConfigured: $isMapTilerConfigured, orsConfigured: $isOrsConfigured)';
  }
}

/// Global provider for mapping and routing configuration.
final mapConfigProvider = Provider<MapConfig>((ref) {
  return MapConfig.fromEnvironment();
});
