class AppConfig {
  // App Information
  static const String appName = 'Cobra';
  static const String appDescription =
      'Cobra App is a streaming platform for watching videos.';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.cobra.cobra';

  // Environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool isDevelopment = !isProduction;

  // App Settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int retryCount = 3;

  // Cache Settings
  static const Duration cacheDuration = Duration(hours: 24);
  static const int cacheSize = 1024 * 1024 * 10; // 10MB

  // Video Player Settings
  static const Duration videoBufferDuration = Duration(seconds: 10);
  static const bool autoPlay = true;

  // Logging Settings
  static const bool enableLogging = !isProduction;
  static const bool enableNetworkLogging = isDevelopment;
}
