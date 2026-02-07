// lib/core/models/device_info.dart

/// Device information collected for authorization and display.
/// Used when device is not authorized - shown to user to share with admin.
class DeviceInfo {
  /// Unique device identifier (Android ID or identifierForVendor on iOS)
  final String deviceKey;

  /// MAC address - often masked on Android 6+, not available on iOS
  final String? macAddress;

  /// Operating system name (Android, iOS)
  final String osName;

  /// OS version (e.g., "14", "17.0")
  final String osVersion;

  /// Device model (e.g., "Pixel 7", "iPhone")
  final String deviceModel;

  /// Device manufacturer (e.g., "Google", "Apple")
  final String manufacturer;

  /// Device brand (e.g., "google", "samsung")
  final String? brand;

  /// App version (e.g., "1.0.0")
  final String appVersion;

  /// Local IP address (optional)
  final String? ipAddress;

  /// Whether this is a physical device (vs emulator)
  final bool isPhysicalDevice;

  const DeviceInfo({
    required this.deviceKey,
    this.macAddress,
    required this.osName,
    required this.osVersion,
    required this.deviceModel,
    required this.manufacturer,
    this.brand,
    required this.appVersion,
    this.ipAddress,
    this.isPhysicalDevice = true,
  });

  /// All fields as a map for display or API payload
  Map<String, String> toDisplayMap() {
    return {
      'Device Key': deviceKey,
      if (macAddress != null) 'MAC Address': macAddress!,
      'OS': '$osName $osVersion',
      'Model': deviceModel,
      'Manufacturer': manufacturer,
      if (brand != null) 'Brand': brand!,
      'App Version': appVersion,
      if (ipAddress != null) 'IP Address': ipAddress!,
    };
  }

  /// For API request body
  Map<String, dynamic> toJson() {
    return {
      'device_key': deviceKey,
      if (macAddress != null) 'mac_address': macAddress,
      'os_name': osName,
      'os_version': osVersion,
      'device_model': deviceModel,
      'manufacturer': manufacturer,
      if (brand != null) 'brand': brand,
      'app_version': appVersion,
      if (ipAddress != null) 'ip_address': ipAddress,
    };
  }
}
