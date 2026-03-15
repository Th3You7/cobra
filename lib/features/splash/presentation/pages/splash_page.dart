import 'package:cobra/core/constants/app_constants.dart';
import 'package:cobra/core/services/device_info_service.dart';
import 'package:cobra/injection/service_locator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';

/// Splash screen - first screen user sees.
/// Checks network, fetches device info, verifies authorization, then navigates.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _hasNetworkError = false;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    setState(() => _hasNetworkError = false);

    // Check network connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    final isConnected = connectivityResult.any(
        (r) => r != ConnectivityResult.none);

    if (!mounted) return;

    if (!isConnected) {
      setState(() => _hasNetworkError = true);
      return;
    }

    // Wait for delay
    await Future.delayed(AppConstants.splashDelay);

    if (!mounted) return;

    // Get the device info
    final deviceInfo = await DeviceInfoService().getDeviceInfo();

    if (!mounted) return;

    // Check authorization
    final deviceAuthService = ref.read(deviceAuthServiceProvider);
    final isAuthorized = await deviceAuthService.checkAuthorization(deviceInfo);

    if (!mounted) return;

    if (isAuthorized) {
      context.go(AppConstants.homeRoute);
    } else {
      context.go(AppConstants.deviceInfoRoute, extra: deviceInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: _hasNetworkError ? _buildErrorContent(context) : _buildLoadingContent(context),
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.play_circle_filled,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          AppConfig.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppConfig.appDescription,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 48),
        CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: 80,
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
        ),
        const SizedBox(height: 24),
        Text(
          'No internet connection',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Please check your connection and try again.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: _initializeAndNavigate,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}
