import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../config/environment.dart';

class AppInitialization {
  static Future<void> initialize() async {
    try {
      // based on the environment, set the environment config
      if (kDebugMode) {
        EnvironmentConfig.setEnvironment(Environment.development);
      } else if (kReleaseMode) {
        EnvironmentConfig.setEnvironment(Environment.production);
      } else if (kProfileMode) {
        EnvironmentConfig.setEnvironment(Environment.staging);
      }
      // Initialize the storage
      await LocalStorage.instance.init();
      // TODO: Initialize the secure storage, Isar and other services here
      // Initialize the secure storage

      if (kDebugMode) {
        Logger().d('Initializing App...');
        Logger().d('Development environment');
      }
    } catch (e) {
      Logger().e('App initialization failed: $e');
      rethrow;
    }
  }

  static Future<bool> isUserAuthenticated() async {
    try {
      final secureStorage = SecureStorage();
      final token = await secureStorage.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      Logger().e('Error checking authentication: $e');
      return false;
    }
  }
}
