// lib/features/playlist/data/services/sync_service.dart

import '../../../../core/models/category.dart';
import '../../../../core/models/channel.dart';
import '../../../../core/models/source.dart';
import '../datasources/m3u_parser.dart';
import '../datasources/xtream_parser.dart';
import '../repositories/categories_repository.dart';
import '../repositories/channels_repository.dart';
import '../repositories/sources_repository.dart';

class SyncService {
  SyncService({
    required SourcesRepository sourcesRepository,
    required ChannelsRepository channelsRepository,
    required CategoriesRepository categoriesRepository,
    required M3uParser m3uParser,
    required XtreamParser xtreamParser,
  })  : _sourcesRepository = sourcesRepository,
        _channelsRepository = channelsRepository,
        _categoriesRepository = categoriesRepository,
        _m3uParser = m3uParser,
        _xtreamParser = xtreamParser;

  final SourcesRepository _sourcesRepository;
  final ChannelsRepository _channelsRepository;
  final CategoriesRepository _categoriesRepository;
  final M3uParser _m3uParser;
  final XtreamParser _xtreamParser;

  /// Starts sync for the given source. Skips if already syncing.
  Future<void> syncSource(String sourceId) async {
    final source = await _sourcesRepository.getById(sourceId);
    if (source == null) return;
    if (source.syncStatus == 'syncing') return;

    await _sourcesRepository.updateSyncStatus(sourceId, 'syncing');

    try {
      if (source.type == 'm3u') {
        await syncM3u(source);
      } else if (source.type == 'xtream' && source.username != null && source.password != null) {
        await syncXtream(source);
      } else if (source.type == 'xtream') {
        await _sourcesRepository.updateSyncStatus(sourceId, 'error');
        return;
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

  /// Fetches Xtream API for live, VOD (movie), and series; saves categories and channels, purges stale.
  Future<void> syncXtream(Source source) async {
    final username = source.username!;
    final password = source.password!;
    final serverUrl = source.url;

    await _syncXtreamLive(source, serverUrl, username, password);
    await _syncXtreamMovie(source, serverUrl, username, password);
    await _syncXtreamSeries(source, serverUrl, username, password);
  }

  Future<void> _syncXtreamLive(Source source, String serverUrl, String username, String password) async {
    final catDtos = await _xtreamParser.getLiveCategories(serverUrl, username, password);
    final categoryIdToOurId = <String, String>{};
    final categories = <Category>[];
    var order = 0;
    for (final c in catDtos) {
      final id = '${source.id}_live_cat_${c.categoryId}';
      categoryIdToOurId[c.categoryId] = id;
      categories.add(Category(id: id, sourceId: source.id, name: c.categoryName, type: 'live', order: order++));
    }
    await _categoriesRepository.saveCategories(source.id, 'live', categories);

    final streamDtos = await _xtreamParser.getLiveStreams(serverUrl, username, password);
    final channels = <Channel>[];
    final keepIds = <String>[];
    var index = 0;
    for (final s in streamDtos) {
      final id = '${source.id}:live_$index';
      keepIds.add(id);
      final categoryId = s.categoryId != null ? categoryIdToOurId[s.categoryId] : null;
      channels.add(Channel(
        id: id,
        sourceId: source.id,
        type: 'live',
        name: s.name,
        categoryId: categoryId,
        streamUrl: s.streamUrl,
        streamIcon: s.streamIcon,
        tvgId: s.streamId,
        order: index,
      ));
      index++;
    }
    await _channelsRepository.saveStreams(source.id, 'live', channels, skipPurge: true);
    await _channelsRepository.purgeStaleItems(source.id, 'live', keepIds);
  }

  Future<void> _syncXtreamMovie(Source source, String serverUrl, String username, String password) async {
    final catDtos = await _xtreamParser.getVodCategories(serverUrl, username, password);
    final categoryIdToOurId = <String, String>{};
    final categories = <Category>[];
    var order = 0;
    for (final c in catDtos) {
      final id = '${source.id}_movie_cat_${c.categoryId}';
      categoryIdToOurId[c.categoryId] = id;
      categories.add(Category(id: id, sourceId: source.id, name: c.categoryName, type: 'movie', order: order++));
    }
    await _categoriesRepository.saveCategories(source.id, 'movie', categories);

    final streamDtos = await _xtreamParser.getVodStreams(serverUrl, username, password);
    final channels = <Channel>[];
    final keepIds = <String>[];
    var index = 0;
    for (final s in streamDtos) {
      final id = '${source.id}:movie_$index';
      keepIds.add(id);
      final categoryId = s.categoryId != null ? categoryIdToOurId[s.categoryId] : null;
      channels.add(Channel(
        id: id,
        sourceId: source.id,
        type: 'movie',
        name: s.name,
        categoryId: categoryId,
        streamUrl: s.streamUrl,
        streamIcon: s.streamIcon,
        order: index,
      ));
      index++;
    }
    await _channelsRepository.saveStreams(source.id, 'movie', channels, skipPurge: true);
    await _channelsRepository.purgeStaleItems(source.id, 'movie', keepIds);
  }

  Future<void> _syncXtreamSeries(Source source, String serverUrl, String username, String password) async {
    final catDtos = await _xtreamParser.getSeriesCategories(serverUrl, username, password);
    final categoryIdToOurId = <String, String>{};
    final categories = <Category>[];
    var order = 0;
    for (final c in catDtos) {
      final id = '${source.id}_series_cat_${c.categoryId}';
      categoryIdToOurId[c.categoryId] = id;
      categories.add(Category(id: id, sourceId: source.id, name: c.categoryName, type: 'series', order: order++));
    }
    await _categoriesRepository.saveCategories(source.id, 'series', categories);

    final seriesList = await _xtreamParser.getSeries(serverUrl, username, password);
    final channels = <Channel>[];
    final keepIds = <String>[];
    var globalIndex = 0;
    for (final series in seriesList) {
      final episodes = await _xtreamParser.getSeriesInfo(serverUrl, username, password, series.seriesId);
      for (final ep in episodes) {
        final id = '${source.id}:series_$globalIndex';
        keepIds.add(id);
        final categoryId = series.categoryId != null ? categoryIdToOurId[series.categoryId] : null;
        channels.add(Channel(
          id: id,
          sourceId: source.id,
          type: 'series',
          name: '${series.name} - ${ep.title}',
          categoryId: categoryId,
          streamUrl: ep.streamUrl,
          streamIcon: series.cover,
          groupTitle: series.name,
          order: globalIndex,
        ));
        globalIndex++;
      }
    }
    await _channelsRepository.saveStreams(source.id, 'series', channels, skipPurge: true);
    await _channelsRepository.purgeStaleItems(source.id, 'series', keepIds);
  }
}
