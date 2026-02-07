// lib/core/services/device_info_service.dart

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/device_info.dart';

/// Collects device information for authorization and display.
class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Gathers device information for the current platform.
  Future<DeviceInfo> getDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (Platform.isAndroid) {
      return _getAndroidDeviceInfo(appVersion);
    } else if (Platform.isIOS) {
      return _getIosDeviceInfo(appVersion);
    } else {
      return DeviceInfo(
        deviceKey: 'unknown',
        osName: Platform.operatingSystem,
        osVersion: Platform.operatingSystemVersion,
        deviceModel: 'Unknown',
        manufacturer: 'Unknown',
        appVersion: appVersion,
        isPhysicalDevice: false,
      );
    }
  }

  Future<DeviceInfo> _getAndroidDeviceInfo(String appVersion) async {
    final android = await _deviceInfo.androidInfo;

    String? macAddress;
    try {
      macAddress = await _networkInfo.getWifiBSSID();
      if (macAddress == null || macAddress.isEmpty) {
        macAddress = null;
      }
    } catch (_) {
      macAddress = null;
    }

    String? ipAddress;
    try {
      ipAddress = await _networkInfo.getWifiIP();
    } catch (_) {
      ipAddress = null;
    }

    return DeviceInfo(
      deviceKey: android.id,
      macAddress: macAddress,
      osName: 'Android',
      osVersion: android.version.release,
      deviceModel: android.model,
      manufacturer: android.manufacturer,
      brand: android.brand,
      appVersion: appVersion,
      ipAddress: ipAddress,
      isPhysicalDevice: android.isPhysicalDevice,
    );
  }

  Future<DeviceInfo> _getIosDeviceInfo(String appVersion) async {
    final ios = await _deviceInfo.iosInfo;

    String? ipAddress;
    try {
      ipAddress = await _networkInfo.getWifiIP();
    } catch (_) {
      ipAddress = null;
    }

    return DeviceInfo(
      deviceKey: ios.identifierForVendor ?? 'unknown',
      macAddress: null,
      osName: 'iOS',
      osVersion: ios.systemVersion,
      deviceModel: ios.model,
      manufacturer: 'Apple',
      brand: 'apple',
      appVersion: appVersion,
      ipAddress: ipAddress,
      isPhysicalDevice: ios.isPhysicalDevice,
    );
  }
}
