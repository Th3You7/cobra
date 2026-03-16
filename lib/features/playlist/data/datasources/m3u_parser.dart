// lib/features/playlist/data/datasources/m3u_parser.dart

import 'package:dio/dio.dart';

/// Raw entry from a parsed M3U playlist (before mapping to Channel/Category).
class M3uEntry {
  final String name;
  final String? groupTitle;
  final String url;
  final String? tvgLogo;
  final String? tvgId;

  const M3uEntry({
    required this.name,
    this.groupTitle,
    required this.url,
    this.tvgLogo,
    this.tvgId,
  });
}

class M3uParser {
  M3uParser({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// Fetches the M3U URL and parses the response. Resolves relative URLs against baseUrl.
  Future<List<M3uEntry>> fetchAndParse(String url) async {
    final response = await _dio.get<String>(url);
    final content = response.data;
    if (content == null || content.isEmpty) return [];
    final baseUrl = _baseUrlFrom(url);
    return parse(content, baseUrl);
  }

  String? _baseUrlFrom(String url) {
    final lastSlash = url.lastIndexOf('/');
    if (lastSlash <= 0) return null;
    return url.substring(0, lastSlash + 1);
  }

  /// Parses M3U content. Handles #EXTINF: lines; next non-empty line is the stream URL.
  List<M3uEntry> parse(String content, [String? baseUrl]) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((s) => s.trim())
        .toList();
    final entries = <M3uEntry>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty || !line.startsWith('#EXTINF:')) continue;
      final attrs = _parseExtInf(line);
      var streamUrl = '';
      for (var j = i + 1; j < lines.length; j++) {
        final next = lines[j];
        if (next.isEmpty || next.startsWith('#')) continue;
        streamUrl = next;
        i = j;
        break;
      }
      if (streamUrl.isEmpty) continue;
      if (baseUrl != null &&
          !streamUrl.startsWith('http://') &&
          !streamUrl.startsWith('https://')) {
        streamUrl = baseUrl + streamUrl;
      }
      entries.add(M3uEntry(
        name: attrs['name'] ?? 'Unknown',
        groupTitle: attrs['groupTitle'],
        url: streamUrl,
        tvgLogo: attrs['tvgLogo'],
        tvgId: attrs['tvgId'],
      ));
    }
    return entries;
  }

  Map<String, String?> _parseExtInf(String line) {
    final result = <String, String?>{};
    final commaIndex = line.indexOf(',');
    if (commaIndex >= 0 && commaIndex < line.length - 1) {
      result['name'] = line.substring(commaIndex + 1).trim();
    }
    final attrRegex = RegExp(r'([a-zA-Z0-9-]+)="([^"]*)"');
    for (final m in attrRegex.allMatches(line)) {
      final key = m.group(1)!.toLowerCase().replaceAll('-', '');
      final value = m.group(2);
      final v = value?.isEmpty == true ? null : value;
      if (key == 'grouptitle') result['groupTitle'] = v;
      else if (key == 'tvglogo') result['tvgLogo'] = v;
      else if (key == 'tvgid') result['tvgId'] = v;
      else if (key == 'tvgname') result['tvgName'] = v;
    }
    result['name'] = result['name'] ?? result['tvgName'] ?? 'Unknown';
    return result;
  }
}
