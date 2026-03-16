// lib/core/models/channel.dart

/// Channel (playlist item) from a source - live stream entry.
class Channel {
  final String id;
  final String sourceId;
  final String type; // e.g. 'live'
  final String name;
  final String? categoryId;
  final String streamUrl;
  final String? streamIcon;
  final String? tvgId;
  final String? groupTitle;
  final int? order;

  const Channel({
    required this.id,
    required this.sourceId,
    required this.type,
    required this.name,
    this.categoryId,
    required this.streamUrl,
    this.streamIcon,
    this.tvgId,
    this.groupTitle,
    this.order,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_id': sourceId,
        'type': type,
        'name': name,
        if (categoryId != null) 'category_id': categoryId,
        'stream_url': streamUrl,
        if (streamIcon != null) 'stream_icon': streamIcon,
        if (tvgId != null) 'tvg_id': tvgId,
        if (groupTitle != null) 'group_title': groupTitle,
        if (order != null) 'order': order,
      };

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      sourceId: json['source_id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String?,
      streamUrl: json['stream_url'] as String,
      streamIcon: json['stream_icon'] as String?,
      tvgId: json['tvg_id'] as String?,
      groupTitle: json['group_title'] as String?,
      order: json['order'] as int?,
    );
  }
}
