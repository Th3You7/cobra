import 'package:cobra/core/models/device_info.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/catchup_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/streaming/presentation/pages/live_page.dart';
import '../../features/streaming/presentation/pages/movies_page.dart';
import '../../features/streaming/presentation/pages/series_page.dart';
import '../../features/playlist/presentation/pages/add_playlist_page.dart';
import '../../features/playlist/presentation/pages/playlist_page.dart';
import '../../features/home/presentation/pages/settings_page.dart';
import '../../features/splash/presentation/pages/device_info_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../constants/app_constants.dart';
import '../widgets/error_page.dart';

class AppRouter {
  static final appRouter = GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'Splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppConstants.deviceInfoRoute,
        name: 'Device Info',
        builder: (context, state) => DeviceInfoPage(
          deviceInfo: state.extra as DeviceInfo?,
        ),
      ),
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'Home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'live',
            name: 'Live',
            builder: (context, state) => const LivePage(),
          ),
          GoRoute(
            path: 'movies',
            name: 'Movies',
            builder: (context, state) => const MoviesPage(),
          ),
          GoRoute(
            path: 'series',
            name: 'Series',
            builder: (context, state) => const SeriesPage(),
          ),
          GoRoute(
            path: 'catchup',
            name: 'Catch Up',
            builder: (context, state) => const CatchupPage(),
          ),
          GoRoute(
            path: 'playlist',
            name: 'Playlist',
            builder: (context, state) => const PlaylistPage(),
          ),
          GoRoute(
            path: 'playlist/add',
            name: 'Add Playlist',
            builder: (context, state) => const AddPlaylistPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'Settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(
      message: 'The page you are looking for does not exist.',
      error: state.error,
    ),
  );
}
