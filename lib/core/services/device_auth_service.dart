// lib/core/services/device_auth_service.dart

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/device_check_response.dart';
import '../models/device_info.dart';
import '../network/api_client.dart';

/// Calls device check API and returns whether the device is authorized.
class DeviceAuthService {
  DeviceAuthService({required ApiClient apiClient}) : _apiClient = apiClient;
  final ApiClient _apiClient;

  /// POST /device/check with [deviceInfo]. Returns true if authorized.
  Future<bool> checkAuthorization(DeviceInfo deviceInfo) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.deviceCheck,
        data: deviceInfo.toJson(),
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) return false;
      final result = DeviceCheckResponse.fromJson(data);
      return result.authorized;
    } on DioException {
      return false;
    }
  }
}
