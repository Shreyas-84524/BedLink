class AppConstants {
  AppConstants._();

  static const String appName = 'BedLink';
  static const String appTagline = 'Right bed. Right hospital. Right now.';
  static const String appVersion = '1.0.0';

  // Timing constants (advisory client-side values matching server constraints)
  static const int offerTimeoutSeconds = 120;
  static const int staleDataThresholdMinutes = 30;
  static const int quickUpdateTargetSeconds = 10;
}
