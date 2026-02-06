import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';

class LocalStorage {
  SharedPreferences? _prefs;
  static LocalStorage? _instance;

  LocalStorage._();

  /// Get singleton instance
  static LocalStorage get instance {
    _instance ??= LocalStorage._();
    return _instance!;
  }

  /// Initialize SharedPreferences - must be called before use
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if storage is initialized
  bool get isInitialized => _prefs != null;

  /// Ensure storage is initialized before operations
  void _ensureInitialized() {
    if (!isInitialized) {
      throw StorageException(
        'LocalStorage not initialized. Call init() first.',
      );
    }
  }

  // String operations
  Future<void> setString(String key, String value) async {
    _ensureInitialized();
    try {
      await _prefs!.setString(key, value);
    } catch (e) {
      throw StorageException('Failed to save string: $e');
    }
  }

  String? getString(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getString(key);
    } catch (e) {
      throw StorageException('Failed to get string: $e');
    }
  }

  // Int operations
  Future<void> setInt(String key, int value) async {
    _ensureInitialized();
    try {
      await _prefs!.setInt(key, value);
    } catch (e) {
      throw StorageException('Failed to save int: $e');
    }
  }

  int? getInt(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      throw StorageException('Failed to get int: $e');
    }
  }

  // Bool operations
  Future<void> setBool(String key, bool value) async {
    _ensureInitialized();
    try {
      await _prefs!.setBool(key, value);
    } catch (e) {
      throw StorageException('Failed to save bool: $e');
    }
  }

  bool? getBool(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      throw StorageException('Failed to get bool: $e');
    }
  }

  // List<String> operations
  Future<void> setStringList(String key, List<String> value) async {
    _ensureInitialized();
    try {
      await _prefs!.setStringList(key, value);
    } catch (e) {
      throw StorageException('Failed to save string list: $e');
    }
  }

  List<String>? getStringList(String key) {
    _ensureInitialized();
    try {
      return _prefs!.getStringList(key);
    } catch (e) {
      throw StorageException('Failed to get string list: $e');
    }
  }

  // Remove
  Future<void> remove(String key) async {
    _ensureInitialized();
    try {
      await _prefs!.remove(key);
    } catch (e) {
      throw StorageException('Failed to remove: $e');
    }
  }

  // Clear all
  Future<void> clear() async {
    _ensureInitialized();
    try {
      await _prefs!.clear();
    } catch (e) {
      throw StorageException('Failed to clear storage: $e');
    }
  }

  // Check if key exists
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }
}
