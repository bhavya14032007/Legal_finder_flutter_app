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

  Map<String, dynamic> toSupabaseJson(String userId) {
    String backendType;
    switch (type) {
      case SavedItemType.conversation:
        backendType = 'chat_session';
        break;
      case SavedItemType.draft:
        backendType = 'draft';
        break;
      case SavedItemType.research:
        backendType = 'research';
        break;
      case SavedItemType.document:
        backendType = 'document';
        break;
    }

    final mergedMeta = Map<String, dynamic>.from(metadata ?? {});
    mergedMeta['content'] = content;
    mergedMeta['subtitle'] = subtitle;

    return {
      'id': id,
      'user_id': userId,
      'item_type': backendType,
      'item_reference': id,
      'title': title,
      'description': subtitle.isNotEmpty ? subtitle : (content.length > 120 ? content.substring(0, 120) : content),
      'metadata': mergedMeta,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    // If returned from Supabase backend schema (005_create_saved_items.sql)
    if (json.containsKey('item_type')) {
      final backendTypeStr = json['item_type'] as String? ?? 'document';
      SavedItemType parsedType;
      switch (backendTypeStr) {
        case 'chat_session':
          parsedType = SavedItemType.conversation;
          break;
        case 'draft':
          parsedType = SavedItemType.draft;
          break;
        case 'research':
          parsedType = SavedItemType.research;
          break;
        case 'document':
        default:
          parsedType = SavedItemType.document;
          break;
      }

      final meta = (json['metadata'] as Map<String, dynamic>?) ?? {};
      return SavedItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? 'Saved Item',
        subtitle: (json['description'] as String?) ?? (meta['subtitle'] as String?) ?? '',
        content: (meta['content'] as String?) ?? (json['description'] as String?) ?? '',
        type: parsedType,
        createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
        metadata: meta,
      );
    }

    SavedItemType parsedType;
    try {
      parsedType = SavedItemType.values.byName(json['type'] as String);
    } catch (_) {
      parsedType = SavedItemType.document;
    }

    return SavedItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      content: json['content'] as String? ?? '',
      type: parsedType,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

