// lib/core/models/device_check_response.dart

/// Response from POST /device/check.
class DeviceCheckResponse {
  final bool authorized;
  final String? message;

  const DeviceCheckResponse({
    required this.authorized,
    this.message,
  });

  factory DeviceCheckResponse.fromJson(Map<String, dynamic> json) {
    return DeviceCheckResponse(
      authorized: json['authorized'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'authorized': authorized,
        if (message != null) 'message': message,
      };
}
