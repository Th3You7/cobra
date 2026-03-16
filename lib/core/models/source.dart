// lib/core/models/source.dart

/// Playlist source: M3U URL or Xtream.
class Source {
  final String id;
  final String type; // 'm3u' | 'xtream'
  final String url;
  final String? name;
  final String syncStatus; // 'idle' | 'syncing' | 'success' | 'error' | 'removing'
  final String? username; // Xtream only
  final String? password; // Xtream only

  const Source({
    required this.id,
    required this.type,
    required this.url,
    this.name,
    this.syncStatus = 'idle',
    this.username,
    this.password,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'url': url,
        if (name != null) 'name': name,
        'sync_status': syncStatus,
        if (username != null) 'username': username,
        if (password != null) 'password': password,
      };

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      name: json['name'] as String?,
      syncStatus: json['sync_status'] as String? ?? 'idle',
      username: json['username'] as String?,
      password: json['password'] as String?,
    );
  }

  Source copyWith({
    String? id,
    String? type,
    String? url,
    String? name,
    String? syncStatus,
    String? username,
    String? password,
  }) {
    return Source(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      name: name ?? this.name,
      syncStatus: syncStatus ?? this.syncStatus,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
