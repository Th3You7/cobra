import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/services/device_auth_service.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/secure_storage.dart';
import '../features/playlist/data/datasources/m3u_parser.dart';
import '../features/playlist/data/datasources/xtream_parser.dart';
import '../features/playlist/data/repositories/categories_repository.dart';
import '../features/playlist/data/repositories/channels_repository.dart';
import '../features/playlist/data/repositories/sources_repository.dart';
import '../features/playlist/data/services/playlist_service.dart';
import '../features/playlist/data/services/sync_service.dart';
import '../core/models/source.dart';

// Network Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final deviceAuthServiceProvider = Provider<DeviceAuthService>((ref) {
  return DeviceAuthService(apiClient: ref.watch(apiClientProvider));
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

// Storage Providers
final localStorageProvider = Provider<LocalStorage>((ref) {
  final storage = LocalStorage.instance;
  // Note: init() should be called before first use
  // This will be handled in app initialization
  return storage;
});

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

// Playlist
final sourcesRepositoryProvider = Provider<SourcesRepository>((ref) {
  return SourcesRepository(localStorage: ref.watch(localStorageProvider));
});

final channelsRepositoryProvider = Provider<ChannelsRepository>((ref) {
  return ChannelsRepository(localStorage: ref.watch(localStorageProvider));
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(localStorage: ref.watch(localStorageProvider));
});

final m3uParserProvider = Provider<M3uParser>((ref) {
  return M3uParser();
});

final xtreamParserProvider = Provider<XtreamParser>((ref) {
  return XtreamParser();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    sourcesRepository: ref.watch(sourcesRepositoryProvider),
    channelsRepository: ref.watch(channelsRepositoryProvider),
    categoriesRepository: ref.watch(categoriesRepositoryProvider),
    m3uParser: ref.watch(m3uParserProvider),
    xtreamParser: ref.watch(xtreamParserProvider),
  );
});

final playlistServiceProvider = Provider<PlaylistService>((ref) {
  return PlaylistService(
    sourcesRepository: ref.watch(sourcesRepositoryProvider),
    channelsRepository: ref.watch(channelsRepositoryProvider),
    categoriesRepository: ref.watch(categoriesRepositoryProvider),
    syncService: ref.watch(syncServiceProvider),
  );
});

final sourcesProvider = FutureProvider<List<Source>>((ref) async {
  return ref.watch(playlistServiceProvider).getSources();
});

final hasPlaylistProvider = FutureProvider<bool>((ref) async {
  final list = await ref.watch(playlistServiceProvider).getSources();
  return list.isNotEmpty;
});

/// Notifier that performs playlist actions and invalidates [sourcesProvider]
/// and [hasPlaylistProvider] so the UI refreshes. Use this for add/remove in the UI.
class PlaylistNotifier extends Notifier<void> {
  @override
  void build() {}

  void _invalidateSources() {
    ref.invalidate(sourcesProvider);
    ref.invalidate(hasPlaylistProvider);
  }

  Future<void> addM3uSource({required String url, String? name}) async {
    await ref.read(playlistServiceProvider).addM3uSource(
          url: url,
          name: name,
          onSyncComplete: _invalidateSources,
        );
    _invalidateSources();
  }

  Future<void> addXtreamSource({
    required String serverUrl,
    required String username,
    required String password,
    String? name,
  }) async {
    await ref.read(playlistServiceProvider).addXtreamSource(
          serverUrl: serverUrl,
          username: username,
          password: password,
          name: name,
          onSyncComplete: _invalidateSources,
        );
    _invalidateSources();
  }

  Future<void> removeSource(String sourceId) async {
    await ref.read(playlistServiceProvider).removeSource(sourceId);
    ref.invalidate(sourcesProvider);
    ref.invalidate(hasPlaylistProvider);
  }

  void retrySync(String sourceId) {
    ref.read(playlistServiceProvider).retrySync(
          sourceId,
          onComplete: _invalidateSources,
        );
    _invalidateSources();
  }
}

final playlistNotifierProvider = NotifierProvider<PlaylistNotifier, void>(PlaylistNotifier.new);
