import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/connectivity_status.dart';

export '../models/connectivity_status.dart';

/// Riverpod Notifier managing mock client network connectivity for frontend resilience testing.
class ConnectivityNotifier extends Notifier<ConnectivityStatus> {
  @override
  ConnectivityStatus build() {
    return ConnectivityStatus.online;
  }

  /// Sets state to online (MED-NET LIVE).
  void setOnline() {
    state = ConnectivityStatus.online;
  }

  /// Sets state to offline.
  void setOffline() {
    state = ConnectivityStatus.offline;
  }

  /// Sets state to reconnecting.
  void setReconnecting() {
    state = ConnectivityStatus.reconnecting;
  }

  /// Toggles through connectivity states for demo evaluation:
  /// online -> offline -> reconnecting -> online.
  void cycleNextState() {
    switch (state) {
      case ConnectivityStatus.online:
        state = ConnectivityStatus.offline;
        break;
      case ConnectivityStatus.offline:
        state = ConnectivityStatus.reconnecting;
        break;
      case ConnectivityStatus.reconnecting:
        state = ConnectivityStatus.online;
        break;
    }
  }
}

/// Global provider for BedLink client connectivity status.
final connectivityProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityStatus>(
  ConnectivityNotifier.new,
);
