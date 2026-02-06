import 'package:go_router/go_router.dart';
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
    ],
    errorBuilder: (context, state) => ErrorPage(
      message: 'The page you are looking for does not exist.',
      error: state.error,
    ),
  );
}
