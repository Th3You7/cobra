import 'environment.dart';

class ApiConfig {
  // Base URL - uses environment configuration
  static String get baseUrl => EnvironmentConfig.baseUrl;

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh-token';
  static const String verifyEmail = '/auth/verify-email';
  static const String verifyPhone = '/auth/verify-phone';
  static const String verifyCode = '/auth/verify-code';
  static const String getProfile = '/user/profile';
  static const String categories = '/categories';
  static const String favorite = '/favorite';

  // Device
  static const String deviceCheck = '/device/check';

  // API Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // API Timeouts
  static Duration get connectTimeout => Duration(seconds: 30);
  static Duration get receiveTimeout => Duration(seconds: 30);
  static Duration get sendTimeout => Duration(seconds: 30);

  // API Retry
  static const int retryCount = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Authentication
  static const String tokenHeader = 'Authorization';
  static const String tokenPrefix = 'Bearer ';
}
