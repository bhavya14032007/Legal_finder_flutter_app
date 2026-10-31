enum SavedItemType {
  document,
  draft,
  research,
  conversation,
}

class SavedItem {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final SavedItemType type;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const SavedItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.type,
    required this.createdAt,
    this.metadata,
  });

  SavedItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    SavedItemType? type,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return SavedItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'type': type.name,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    return SavedItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      content: json['content'] as String,
      type: SavedItemType.values.byName(json['type'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
