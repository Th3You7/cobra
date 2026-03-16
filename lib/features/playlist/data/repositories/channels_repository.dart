// lib/features/playlist/data/repositories/channels_repository.dart

import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/models/channel.dart';
import '../../../../core/storage/local_storage.dart';

class ChannelsRepository {
  ChannelsRepository({required LocalStorage localStorage})
      : _localStorage = localStorage;
  final LocalStorage _localStorage;

  Future<List<Channel>> getAll() async {
    final raw = _localStorage.getString(StorageKeys.channels);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Channel>> getBySourceId(String sourceId) async {
    final list = await getAll();
    return list.where((c) => c.sourceId == sourceId).toList();
  }

  Future<void> saveStreams(
    String sourceId,
    String type,
    List<Channel> items, {
    bool skipPurge = true,
  }) async {
    final list = await getAll();
    list.removeWhere((c) => c.sourceId == sourceId && c.type == type);
    list.addAll(items);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.channels, encoded);
  }

  Future<void> purgeStaleItems(
    String sourceId,
    String type,
    List<String> keepIds,
  ) async {
    final list = await getAll();
    final keepSet = keepIds.toSet();
    list.removeWhere((c) =>
        c.sourceId == sourceId &&
        c.type == type &&
        !keepSet.contains(c.id));
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.channels, encoded);
  }

  /// Removes all channels for the given source (all types).
  Future<void> removeBySourceId(String sourceId) async {
    final list = await getAll();
    list.removeWhere((c) => c.sourceId == sourceId);
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await _localStorage.setString(StorageKeys.channels, encoded);
  }
}
