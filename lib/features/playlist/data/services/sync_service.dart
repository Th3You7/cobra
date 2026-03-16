// lib/features/playlist/data/services/sync_service.dart

import '../../../../core/models/category.dart';
import '../../../../core/models/channel.dart';
import '../../../../core/models/source.dart';
import '../datasources/m3u_parser.dart';
import '../repositories/categories_repository.dart';
import '../repositories/channels_repository.dart';
import '../repositories/sources_repository.dart';

class SyncService {
  SyncService({
    required SourcesRepository sourcesRepository,
    required ChannelsRepository channelsRepository,
    required CategoriesRepository categoriesRepository,
    required M3uParser m3uParser,
  })  : _sourcesRepository = sourcesRepository,
        _channelsRepository = channelsRepository,
        _categoriesRepository = categoriesRepository,
        _m3uParser = m3uParser;

  final SourcesRepository _sourcesRepository;
  final ChannelsRepository _channelsRepository;
  final CategoriesRepository _categoriesRepository;
  final M3uParser _m3uParser;

  /// Starts sync for the given source. Skips if already syncing.
  Future<void> syncSource(String sourceId) async {
    final source = await _sourcesRepository.getById(sourceId);
    if (source == null) return;
    if (source.syncStatus == 'syncing') return;

    await _sourcesRepository.updateSyncStatus(sourceId, 'syncing');

    try {
      if (source.type == 'm3u') {
        await syncM3u(source);
      }
      await _sourcesRepository.updateSyncStatus(sourceId, 'success');
    } catch (_) {
      await _sourcesRepository.updateSyncStatus(sourceId, 'error');
    }
  }

  /// Fetches M3U, parses, saves categories and channels in batches, then purges stale.
  Future<void> syncM3u(Source source) async {
    final entries = await _m3uParser.fetchAndParse(source.url);
    if (entries.isEmpty) return;

    final groupTitles = <String>{};
    for (final e in entries) {
      if (e.groupTitle != null && e.groupTitle!.isNotEmpty) {
        groupTitles.add(e.groupTitle!);
      }
    }
    if (groupTitles.isEmpty) groupTitles.add('Uncategorized');

    final groupToId = <String, String>{};
    final categories = <Category>[];
    var order = 0;
    for (final g in groupTitles) {
      final id = '${source.id}_cat_${g.hashCode.abs()}';
      groupToId[g] = id;
      categories.add(Category(
        id: id,
        sourceId: source.id,
        name: g,
        type: 'live',
        order: order++,
      ));
    }

    await _categoriesRepository.saveCategories(source.id, 'live', categories);

    final allChannels = <Channel>[];
    final allIds = <String>[];
    var index = 0;
    for (final e in entries) {
      final groupTitle = e.groupTitle ?? 'Uncategorized';
      final categoryId = groupToId[groupTitle];
      final streamId = '${index}_${e.url.hashCode.abs()}';
      final id = '${source.id}:$streamId';
      allIds.add(id);
      allChannels.add(Channel(
        id: id,
        sourceId: source.id,
        type: 'live',
        name: e.name,
        categoryId: categoryId,
        streamUrl: e.url,
        streamIcon: e.tvgLogo,
        tvgId: e.tvgId,
        groupTitle: e.groupTitle,
        order: index,
      ));
      index++;
    }

    await _channelsRepository.saveStreams(
      source.id,
      'live',
      allChannels,
      skipPurge: true,
    );
    await _channelsRepository.purgeStaleItems(source.id, 'live', allIds);
  }
}
