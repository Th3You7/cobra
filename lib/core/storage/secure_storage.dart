import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../errors/exceptions.dart';
import '../constants/storage_keys.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Token operations
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.authToken, value: token);
    } catch (e) {
      throw StorageException('Failed to save token: $e');
    }
  }
  
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: StorageKeys.authToken);
    } catch (e) {
      throw StorageException('Failed to get token: $e');
    }
  }
  
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: StorageKeys.authToken);
    } catch (e) {
      throw StorageException('Failed to delete token: $e');
    }
  }
  
  // Refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: StorageKeys.refreshToken, value: token);
    } catch (e) {
      throw StorageException('Failed to save refresh token: $e');
    }
  }
  
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageKeys.refreshToken);
    } catch (e) {
      throw StorageException('Failed to get refresh token: $e');
    }
  }

  Future<void> deleteRefreshToken() async {
    try {
      await _storage.delete(key: StorageKeys.refreshToken);
    } catch (e) {
      throw StorageException('Failed to delete refresh token: $e');
    }
  }

  // Generic operations
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw StorageException('Failed to write: $e');
    }
  }
  
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw StorageException('Failed to read: $e');
    }
  }
  
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw StorageException('Failed to delete: $e');
    }
  }
  
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to delete all: $e');
    }
  }
}
