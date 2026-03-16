// lib/features/playlist/data/services/playlist_service.dart

import '../../../../core/models/source.dart';
import '../repositories/categories_repository.dart';
import '../repositories/channels_repository.dart';
import '../repositories/sources_repository.dart';
import 'sync_service.dart';

class PlaylistService {
  PlaylistService({
    required SourcesRepository sourcesRepository,
    required ChannelsRepository channelsRepository,
    required CategoriesRepository categoriesRepository,
    required SyncService syncService,
  })  : _sourcesRepository = sourcesRepository,
        _channelsRepository = channelsRepository,
        _categoriesRepository = categoriesRepository,
        _syncService = syncService;

  final SourcesRepository _sourcesRepository;
  final ChannelsRepository _channelsRepository;
  final CategoriesRepository _categoriesRepository;
  final SyncService _syncService;

  /// Returns the list of all saved sources.
  Future<List<Source>> getSources() async {
    return _sourcesRepository.getAll();
  }

  /// Adds an M3U source, saves it, and starts background sync (fire-and-forget).
  Future<void> addM3uSource({required String url, String? name}) async {
    final id = 'm3u_${DateTime.now().millisecondsSinceEpoch}';
    final source = Source(
      id: id,
      type: 'm3u',
      url: url.trim(),
      name: name?.trim(),
      syncStatus: 'idle',
    );
    await _sourcesRepository.add(source);
    _syncService.syncSource(source.id);
  }

  /// Adds an Xtream source, saves it, and starts background sync (fire-and-forget).
  Future<void> addXtreamSource({
    required String serverUrl,
    required String username,
    required String password,
    String? name,
  }) async {
    final id = 'xtream_${DateTime.now().millisecondsSinceEpoch}';
    final source = Source(
      id: id,
      type: 'xtream',
      url: serverUrl.trim(),
      name: name?.trim(),
      username: username.trim(),
      password: password,
      syncStatus: 'idle',
    );
    await _sourcesRepository.add(source);
    _syncService.syncSource(source.id);
  }

  /// Removes the source and all its channels and categories. On failure sets
  /// source syncStatus to 'error' so the user can retry.
  Future<void> removeSource(String sourceId) async {
    final source = await _sourcesRepository.getById(sourceId);
    if (source == null) return;
    if (source.syncStatus == 'removing') return;

    await _sourcesRepository.updateSyncStatus(sourceId, 'removing');

    try {
      await _channelsRepository.removeBySourceId(sourceId);
      await _categoriesRepository.removeBySourceId(sourceId);
      await _sourcesRepository.remove(sourceId);
    } catch (_) {
      final stillExists = await _sourcesRepository.getById(sourceId);
      if (stillExists != null) {
        await _sourcesRepository.updateSyncStatus(sourceId, 'error');
      }
    }
  }
}
