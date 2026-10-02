class Formatters {
  Formatters._();

  /// Format countdown seconds to mm:ss display string (e.g. 120 -> "02:00").
  static String formatCountdown(int seconds) {
    if (seconds <= 0) return '00:00';
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String minStr = minutes.toString().padLeft(2, '0');
    final String secStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  /// Format ETA in seconds to human readable minutes string (e.g. 720 -> "12 min").
  static String formatEta(int seconds) {
    if (seconds <= 0) return '0 min';
    final int minutes = (seconds / 60).ceil();
    return '$minutes min';
  }

  /// Format distance in meters to km string (e.g. 4200 -> "4.2 km").
  static String formatDistance(int meters) {
    if (meters < 1000) {
      return '$meters m';
    }
    final double km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }
}
