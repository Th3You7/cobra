// lib/features/playlist/data/repositories/categories_repository.dart

import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/models/category.dart';
import '../../../../core/storage/local_storage.dart';

class CategoriesRepository {
  CategoriesRepository({required LocalStorage localStorage})
      : _localStorage = localStorage;
  final LocalStorage _localStorage;

  Future<List<Category>> getAll() async {
    final raw = _localStorage.getString(StorageKeys.categories);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Category>> getBySourceId(String sourceId) async {
    final list = await getAll();
    return list.where((c) => c.sourceId == sourceId).toList();
  }

  Future<void> saveCategories(
    String sourceId,
    String type,
    List<Category> categories,
  ) async {
    final list = await getAll();
    list.removeWhere((c) => c.sourceId == sourceId && c.type == type);
    list.addAll(categories);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.categories, encoded);
  }

  /// Removes all categories for the given source.
  Future<void> removeBySourceId(String sourceId) async {
    final list = await getAll();
    list.removeWhere((c) => c.sourceId == sourceId);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.categories, encoded);
  }
}
