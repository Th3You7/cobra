// lib/features/playlist/data/datasources/xtream_parser.dart

import 'package:dio/dio.dart';

/// Raw category entry from Xtream API (live, movie, or series).
class XtreamCategoryEntry {
  final String categoryId;
  final String categoryName;

  const XtreamCategoryEntry({required this.categoryId, required this.categoryName});
}

/// Raw live stream entry from Xtream API with resolved stream URL.
class XtreamLiveEntry {
  final String streamId;
  final String name;
  final String? streamIcon;
  final String? categoryId;
  final String streamUrl;
  final int? num;

  const XtreamLiveEntry({
    required this.streamId,
    required this.name,
    this.streamIcon,
    this.categoryId,
    required this.streamUrl,
    this.num,
  });
}

/// Raw VOD/movie stream entry from Xtream API with resolved stream URL.
class XtreamVodEntry {
  final String streamId;
  final String name;
  final String? streamIcon;
  final String? categoryId;
  final String streamUrl;
  final String? containerExtension;

  const XtreamVodEntry({
    required this.streamId,
    required this.name,
    this.streamIcon,
    this.categoryId,
    required this.streamUrl,
    this.containerExtension,
  });
}

/// Raw series entry from Xtream API (top-level list).
class XtreamSeriesEntry {
  final String seriesId;
  final String name;
  final String? cover;
  final String? plot;
  final String? categoryId;

  const XtreamSeriesEntry({
    required this.seriesId,
    required this.name,
    this.cover,
    this.plot,
    this.categoryId,
  });
}

/// Raw series episode entry from Xtream API with resolved stream URL.
class XtreamEpisodeEntry {
  final String episodeId;
  final String title;
  final String? containerExtension;
  final String streamUrl;
  final int? seasonNumber;
  final int? episodeNum;

  const XtreamEpisodeEntry({
    required this.episodeId,
    required this.title,
    this.containerExtension,
    required this.streamUrl,
    this.seasonNumber,
    this.episodeNum,
  });
}

class XtreamParser {
  XtreamParser({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  String _normalizeBase(String serverUrl) {
    final s = serverUrl.trim();
    if (s.endsWith('/')) return s.substring(0, s.length - 1);
    return s;
  }

  String _apiUrl(String serverUrl, String username, String password, [String? action, Map<String, String>? extra]) {
    final base = _normalizeBase(serverUrl);
    var url = '$base/player_api.php?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';
    if (action != null && action.isNotEmpty) {
      url += '&action=$action';
    }
    if (extra != null) {
      for (final e in extra.entries) {
        url += '&${e.key}=${Uri.encodeComponent(e.value)}';
      }
    }
    return url;
  }

  String _liveStreamUrl(String base, String username, String password, String streamId) {
    return '$base/live/$username/$password/$streamId.m3u8';
  }

  String _movieStreamUrl(String base, String username, String password, String streamId, [String? ext]) {
    final extension = ext ?? 'mp4';
    return '$base/movie/$username/$password/$streamId.$extension';
  }

  String _seriesStreamUrl(String base, String username, String password, String episodeId, [String? ext]) {
    final extension = ext ?? 'mp4';
    return '$base/series/$username/$password/$episodeId.$extension';
  }

  Future<Map<String, dynamic>> _get(String serverUrl, String username, String password, String action, [Map<String, String>? extra]) async {
    final url = _apiUrl(serverUrl, username, password, action, extra);
    final response = await _dio.get<dynamic>(url);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is List) return {'list': data};
    return {};
  }

  Future<List<XtreamCategoryEntry>> getLiveCategories(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_live_categories');
    final list = data['list'] ?? data['categories'] ?? data;
    if (list is! List) return [];
    final result = <XtreamCategoryEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final id = _str(e['category_id']) ?? '';
      final name = _str(e['category_name']) ?? 'Uncategorized';
      result.add(XtreamCategoryEntry(categoryId: id, categoryName: name));
    }
    return result;
  }

  Future<List<XtreamLiveEntry>> getLiveStreams(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_live_streams');
    final list = data['list'] ?? data['available_channels'] ?? data['channels'] ?? data;
    if (list is! List) return [];
    final base = _normalizeBase(serverUrl);
    final result = <XtreamLiveEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final streamId = _str(e['stream_id']) ?? _str(e['id']) ?? '';
      if (streamId.isEmpty) continue;
      final name = _str(e['name']) ?? 'Unknown';
      final streamUrl = _liveStreamUrl(base, username, password, streamId);
      result.add(XtreamLiveEntry(
        streamId: streamId,
        name: name,
        streamIcon: _str(e['stream_icon']),
        categoryId: _str(e['category_id']),
        streamUrl: streamUrl,
        num: e['num'] is int ? e['num'] as int : null,
      ));
    }
    return result;
  }

  Future<List<XtreamCategoryEntry>> getVodCategories(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_vod_categories');
    final list = data['list'] ?? data['movie_categories'] ?? data['categories'] ?? data;
    if (list is! List) return [];
    final result = <XtreamCategoryEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final id = _str(e['category_id']) ?? '';
      final name = _str(e['category_name']) ?? 'Uncategorized';
      result.add(XtreamCategoryEntry(categoryId: id, categoryName: name));
    }
    return result;
  }

  Future<List<XtreamVodEntry>> getVodStreams(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_vod_streams');
    final list = data['list'] ?? data['movies'] ?? data;
    if (list is! List) return [];
    final base = _normalizeBase(serverUrl);
    final result = <XtreamVodEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final streamId = _str(e['stream_id'] ?? e['id']) ?? '';
      if (streamId.isEmpty) continue;
      final name = _str(e['name']) ?? _str(e['title']) ?? 'Unknown';
      final ext = _str(e['container_extension']) ?? 'mp4';
      final streamUrl = _movieStreamUrl(base, username, password, streamId, ext);
      result.add(XtreamVodEntry(
        streamId: streamId,
        name: name,
        streamIcon: _str(e['stream_icon'] ?? e['cover']),
        categoryId: _str(e['category_id']),
        streamUrl: streamUrl,
        containerExtension: ext,
      ));
    }
    return result;
  }

  Future<List<XtreamCategoryEntry>> getSeriesCategories(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_series_categories');
    final list = data['list'] ?? data['series_categories'] ?? data['categories'] ?? data;
    if (list is! List) return [];
    final result = <XtreamCategoryEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final id = _str(e['category_id']) ?? '';
      final name = _str(e['category_name']) ?? 'Uncategorized';
      result.add(XtreamCategoryEntry(categoryId: id, categoryName: name));
    }
    return result;
  }

  Future<List<XtreamSeriesEntry>> getSeries(String serverUrl, String username, String password) async {
    final data = await _get(serverUrl, username, password, 'get_series');
    final list = data['list'] ?? data['series'] ?? data;
    if (list is! List) return [];
    final result = <XtreamSeriesEntry>[];
    for (final e in list) {
      if (e is! Map<String, dynamic>) continue;
      final seriesId = _str(e['series_id'] ?? e['id']) ?? '';
      if (seriesId.isEmpty) continue;
      result.add(XtreamSeriesEntry(
        seriesId: seriesId,
        name: _str(e['name']) ?? 'Unknown',
        cover: _str(e['cover']),
        plot: _str(e['plot']),
        categoryId: _str(e['category_id']),
      ));
    }
    return result;
  }

  Future<List<XtreamEpisodeEntry>> getSeriesInfo(String serverUrl, String username, String password, String seriesId) async {
    final data = await _get(serverUrl, username, password, 'get_series_info', {'series_id': seriesId});
    var payload = data;
    if (data['list'] != null && data['list'] is Map) payload = data['list'] as Map<String, dynamic>;
    if (data['info'] != null && data['info'] is Map) payload = data['info'] as Map<String, dynamic>;
    final base = _normalizeBase(serverUrl);
    final result = <XtreamEpisodeEntry>[];

    final episodesMap = payload['episodes'];
    if (episodesMap is Map) {
      for (final seasonEntry in episodesMap.entries) {
        final seasonList = seasonEntry.value;
        if (seasonList is! List) continue;
        final seasonNum = int.tryParse(seasonEntry.key.toString()) ?? 0;
        for (final ep in seasonList) {
          if (ep is! Map<String, dynamic>) continue;
          final episodeId = _str(ep['id']) ?? _str(ep['episode_id']) ?? '';
          if (episodeId.isEmpty) continue;
          final title = _str(ep['title']) ?? _str(ep['name']) ?? 'E${ep['episode_num'] ?? ''}';
          final ext = _str(ep['container_extension']) ?? 'mp4';
          final streamUrl = _seriesStreamUrl(base, username, password, episodeId, ext);
          result.add(XtreamEpisodeEntry(
            episodeId: episodeId,
            title: title,
            containerExtension: ext,
            streamUrl: streamUrl,
            seasonNumber: seasonNum,
            episodeNum: ep['episode_num'] is int ? ep['episode_num'] as int : null,
          ));
        }
      }
    }

    if (result.isNotEmpty) return result;
    final seasonsList = payload['seasons'];
    if (seasonsList is List) {
      for (final season in seasonsList) {
        if (season is! Map<String, dynamic>) continue;
        final seasonNum = season['season_number'] is int ? season['season_number'] as int : 0;
        final episodes = season['episodes'];
        if (episodes is! List) continue;
        for (final ep in episodes) {
          if (ep is! Map<String, dynamic>) continue;
          final episodeId = _str(ep['id']) ?? _str(ep['episode_id']) ?? '';
          if (episodeId.isEmpty) continue;
          final title = _str(ep['title']) ?? _str(ep['name']) ?? 'E${ep['episode_num'] ?? ''}';
          final ext = _str(ep['container_extension']) ?? 'mp4';
          final streamUrl = _seriesStreamUrl(base, username, password, episodeId, ext);
          result.add(XtreamEpisodeEntry(
            episodeId: episodeId,
            title: title,
            containerExtension: ext,
            streamUrl: streamUrl,
            seasonNumber: seasonNum,
            episodeNum: ep['episode_num'] is int ? ep['episode_num'] as int : null,
          ));
        }
      }
    }
    return result;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    return v.toString();
  }
}
