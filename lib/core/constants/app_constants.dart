class AppConstants {
  // App Info
  static const String appName = 'Cobra IPTV';

  // Routes — aligned with [AppRouter.appRouter]
  // Top-level: /, /device-info, /home
  static const String splashRoute = '/';
  static const String deviceInfoRoute = '/device-info';
  static const String homeRoute = '/home';

  // Home child routes: /home/<path>
  static const String homeLiveRoute = '/home/live';
  static const String homeMoviesRoute = '/home/movies';
  static const String homeSeriesRoute = '/home/series';
  static const String homeCatchupRoute = '/home/catchup';
  static const String homePlaylistRoute = '/home/playlist';
  static const String homePlaylistAddRoute = '/home/playlist/add';
  static const String homeSettingsRoute = '/home/settings';

  // Planned / not yet in router
  static const String loginRoute = '/login';
  static const String playerRoute = '/player';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Xtream sync limits (until real DB — avoid OOM on large playlists)
  static const int xtreamMaxCategoriesPerType = 200;
  static const int xtreamMaxLiveChannels = 2000;
  static const int xtreamMaxMovieChannels = 1000;
  static const int xtreamMaxSeriesCount = 100;
  static const int xtreamMaxSeriesChannels = 2000;

  // Image Sizes
  static const double channelLogoSize = 80.0;
  static const double thumbnailHeight = 200.0;

  // Debounce/Delay
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 2);
}
