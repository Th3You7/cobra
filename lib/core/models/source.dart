// lib/core/models/source.dart

/// Playlist source: M3U URL or Xtream (later).
class Source {
  final String id;
  final String type; // 'm3u' | 'xtream'
  final String url;
  final String? name;
  final String syncStatus; // 'idle' | 'syncing' | 'success' | 'error'

  const Source({
    required this.id,
    required this.type,
    required this.url,
    this.name,
    this.syncStatus = 'idle',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
        if (name != null) 'name': name,
        'sync_status': syncStatus,
      };

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      name: json['name'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'idle',
    );
  }

  Source copyWith({
    String? id,
    String? type,
    String? url,
    String? name,
    String? syncStatus,
  }) {
    return Source(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      name: name ?? this.name,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
