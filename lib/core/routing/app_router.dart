import 'package:cobra/core/models/device_info.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
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
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(
      message: 'The page you are looking for does not exist.',
      error: state.error,
    ),
  );
}
