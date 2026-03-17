// lib/features/playlist/data/services/playlist_service.dart

import '../../../../core/errors/exceptions.dart';
import '../../../../core/models/source.dart';
import '../../../../core/utils/validators.dart';
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

  /// Normalizes URL for duplicate comparison (trim, remove trailing slash).
  static String _normalizeUrl(String url) {
    final s = url.trim();
    if (s.endsWith('/')) return s.substring(0, s.length - 1);
    return s;
  }

  /// Returns the list of all saved sources.
  Future<List<Source>> getSources() async {
    return _sourcesRepository.getAll();
  }

  /// Adds an M3U source, saves it, and starts background sync (fire-and-forget).
  /// [onSyncComplete] is called when sync finishes so UI can refresh status.
  /// Throws [ValidationException] if URL is invalid or already added.
  Future<void> addM3uSource({
    required String url,
    String? name,
    void Function()? onSyncComplete,
  }) async {
    final trimmed = url.trim();
    if (!Validators.isValidUrl(trimmed)) {
      throw const ValidationException(
        'Enter a valid M3U URL (e.g. https://example.com/playlist.m3u)',
      );
    }
    final normalized = _normalizeUrl(trimmed);
    final existing = await _sourcesRepository.getAll();
    final alreadyAdded = existing.any(
      (s) => s.type == 'm3u' && _normalizeUrl(s.url) == normalized,
    );
    if (alreadyAdded) {
      throw const ValidationException('This playlist is already added.');
    }
    final id = 'm3u_${DateTime.now().millisecondsSinceEpoch}';
    final source = Source(
      id: id,
      type: 'm3u',
      url: trimmed,
      name: name?.trim(),
      syncStatus: 'idle',
    );
    await _sourcesRepository.add(source);
    _syncService.syncSource(source.id, onComplete: onSyncComplete);
  }

  /// Adds an Xtream source, saves it, and starts background sync (fire-and-forget).
  /// [onSyncComplete] is called when sync finishes so UI can refresh status.
  /// Throws [ValidationException] if URL is invalid or this account is already added.
  Future<void> addXtreamSource({
    required String serverUrl,
    required String username,
    required String password,
    String? name,
    void Function()? onSyncComplete,
  }) async {
    final trimmedUrl = serverUrl.trim();
    if (!Validators.isValidUrl(trimmedUrl)) {
      throw const ValidationException(
        'Enter a valid server URL (e.g. http://server:8080)',
      );
    }
    final normalizedUrl = _normalizeUrl(trimmedUrl);
    final trimmedUsername = username.trim();
    final existing = await _sourcesRepository.getAll();
    final alreadyAdded = existing.any(
      (s) =>
          s.type == 'xtream' &&
          _normalizeUrl(s.url) == normalizedUrl &&
          (s.username?.trim() ?? '') == trimmedUsername,
    );
    if (alreadyAdded) {
      throw const ValidationException('This Xtream account is already added.');
    }
    final id = 'xtream_${DateTime.now().millisecondsSinceEpoch}';
    final source = Source(
      id: id,
      type: 'xtream',
      url: trimmedUrl,
      name: name?.trim(),
      username: trimmedUsername,
      password: password,
      syncStatus: 'idle',
    );
    await _sourcesRepository.add(source);
    _syncService.syncSource(source.id, onComplete: onSyncComplete);
  }

  /// Triggers a sync for the given source (e.g. after error). Fire-and-forget.
  /// [onComplete] is called when sync finishes so UI can refresh status.
  void retrySync(String sourceId, {void Function()? onComplete}) {
    _syncService.syncSource(sourceId, onComplete: onComplete);
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
