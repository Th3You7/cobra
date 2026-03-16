// lib/features/playlist/data/repositories/sources_repository.dart

import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/models/source.dart';
import '../../../../core/storage/local_storage.dart';

class SourcesRepository {
  SourcesRepository({required LocalStorage localStorage})
      : _localStorage = localStorage;
  final LocalStorage _localStorage;

  Future<List<Source>> getAll() async {
    final raw = _localStorage.getString(StorageKeys.sources);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Source.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Source?> getById(String sourceId) async {
    final list = await getAll();
    try {
      return list.firstWhere((s) => s.id == sourceId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAll(List<Source> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.sources, encoded);
  }

  Future<void> add(Source source) async {
    final list = await getAll();
    list.add(source);
    await saveAll(list);
  }

  Future<void> updateSyncStatus(String sourceId, String status) async {
    final list = await getAll();
    final index = list.indexWhere((s) => s.id == sourceId);
    if (index < 0) return;
    list[index] = list[index].copyWith(syncStatus: status);
    await saveAll(list);
  }

  Future<void> remove(String sourceId) async {
    final list = await getAll();
    list.removeWhere((s) => s.id == sourceId);
    await saveAll(list);
  }
}
