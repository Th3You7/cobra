import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity = Connectivity();

  /// Check if device is connected to internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Get current connectivity result
  Future<ConnectivityResult> get connectivityResult async {
    final result = await _connectivity.checkConnectivity();
    return result.first;
  }

  /// Stream of connectivity changes
  Stream<ConnectivityResult> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) => result.first);
  }

  /// Check if connected via WiFi
  Future<bool> get isWifi async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  /// Check if connected via mobile data
  Future<bool> get isMobile async {
    final result = await _connectivity.checkConnectivity();
    return result == ConnectivityResult.mobile;
  }
}
