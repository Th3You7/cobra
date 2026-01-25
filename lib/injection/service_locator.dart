import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';

// Network Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

// Storage Providers
final localStorageProvider = Provider<LocalStorage>((ref) {
  final storage = LocalStorage();
  // Note: init() should be called before first use
  // This will be handled in app initialization
  return storage;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});
