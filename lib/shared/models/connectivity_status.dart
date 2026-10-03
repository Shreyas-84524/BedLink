import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Network connectivity states for the BedLink client interface.
enum ConnectivityStatus {
  online,
  offline,
  reconnecting;

  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;
  bool get isReconnecting => this == ConnectivityStatus.reconnecting;

  String get label {
    switch (this) {
      case ConnectivityStatus.online:
        return 'MED-NET LIVE';
      case ConnectivityStatus.offline:
        return 'OFFLINE';
      case ConnectivityStatus.reconnecting:
        return 'RECONNECTING';
    }
  }

  String get description {
    switch (this) {
      case ConnectivityStatus.online:
        return 'Connected to city-wide emergency dispatch matrix.';
      case ConnectivityStatus.offline:
        return 'Operating in offline mode. Displaying last-known cached data.';
      case ConnectivityStatus.reconnecting:
        return 'Re-establishing encrypted medical data link...';
    }
  }

  Color get indicatorColor {
    switch (this) {
      case ConnectivityStatus.online:
        return AppColors.secondaryTeal;
      case ConnectivityStatus.offline:
        return AppColors.warningDark;
      case ConnectivityStatus.reconnecting:
        return AppColors.infoBlue;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ConnectivityStatus.online:
        return AppColors.tealSurface;
      case ConnectivityStatus.offline:
        return AppColors.warningSurface;
      case ConnectivityStatus.reconnecting:
        return AppColors.infoSurface;
    }
  }

  Color get borderColor {
    switch (this) {
      case ConnectivityStatus.online:
        return AppColors.tealBorder;
      case ConnectivityStatus.offline:
        return AppColors.warningBorder;
      case ConnectivityStatus.reconnecting:
        return AppColors.infoBorder;
    }
  }
}
