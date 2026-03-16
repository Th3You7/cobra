// lib/features/playlist/data/services/playlist_service.dart

import '../../../../core/models/source.dart';
import '../repositories/sources_repository.dart';
import 'sync_service.dart';

class PlaylistService {
  PlaylistService({
    required SourcesRepository sourcesRepository,
    required SyncService syncService,
  })  : _sourcesRepository = sourcesRepository,
        _syncService = syncService;

  final SourcesRepository _sourcesRepository;
  final SyncService _syncService;

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
}
