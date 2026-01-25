/// Environment configuration for different build flavors
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  static Environment _currentEnvironment = Environment.development;
  
  /// Get current environment
  static Environment get current => _currentEnvironment;
  
  /// Set environment (typically from compile-time constant)
  static void setEnvironment(Environment env) {
    _currentEnvironment = env;
  }
  
  /// Check if current environment is development
  static bool get isDevelopment => _currentEnvironment == Environment.development;
  
  /// Check if current environment is staging
  static bool get isStaging => _currentEnvironment == Environment.staging;
  
  /// Check if current environment is production
  static bool get isProduction => _currentEnvironment == Environment.production;
  
  /// Get base URL based on environment
  static String get baseUrl {
    switch (_currentEnvironment) {
      case Environment.development:
        return 'https://api-dev.cobra.com';
      case Environment.staging:
        return 'https://api-staging.cobra.com';
      case Environment.production:
        return 'https://api.cobra.com';
    }
  }
  
  /// Get API key based on environment (if needed)
  static String? get apiKey {
    switch (_currentEnvironment) {
      case Environment.development:
        return null; // Use from secure storage or config
      case Environment.staging:
        return null;
      case Environment.production:
        return null;
    }
  }
}
