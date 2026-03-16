// lib/core/models/category.dart

/// Category (group) for channels from a source.
class Category {
  final String id;
  final String sourceId;
  final String name;
  final String type; // e.g. 'live'
  final int? order;

  const Category({
    required this.id,
    required this.sourceId,
    required this.name,
    this.type = 'live',
    this.order,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_id': sourceId,
        'name': name,
        'type': type,
        if (order != null) 'order': order,
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      sourceId: json['source_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'live',
      order: json['order'] as int?,
    );
  }
}
