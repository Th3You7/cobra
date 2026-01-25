class AppConstants {
  // App Info
  static const String appName = 'Cobra IPTV';
  
  // Routes (will be used later)
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String playerRoute = '/player';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Image Sizes
  static const double channelLogoSize = 80.0;
  static const double thumbnailHeight = 200.0;
  
  // Debounce/Delay
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 2);
}
