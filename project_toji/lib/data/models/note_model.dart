class NoteModel {
  final String id;
  final String title;
  final String content; // Plain-text representation for search and preview
  final String?
  contentJson; // Serialized Quill Delta JSON string for rich formatting
  final List<String> labelIds; // Custom label IDs assigned to this note
  final String category; // Legacy category fallback ('Personal', 'Gym', etc.)
  final bool isPinned;
  final int? reminderId; // Associated reminder ID if scheduled
  final DateTime? reminderDateTime; // Quick cache for card badge display
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.contentJson,
    this.labelIds = const [],
    this.category = 'Personal',
    this.isPinned = false,
    this.reminderId,
    this.reminderDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? contentJson,
    List<String>? labelIds,
    String? category,
    bool? isPinned,
    int? reminderId,
    DateTime? reminderDateTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentJson: contentJson ?? this.contentJson,
      labelIds: labelIds ?? this.labelIds,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      reminderId: reminderId ?? this.reminderId,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentJson': contentJson,
      'labelIds': labelIds,
      'category': category,
      'isPinned': isPinned,
      'reminderId': reminderId,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      contentJson: json['contentJson'] as String?,
      labelIds:
          (json['labelIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      category: json['category'] as String? ?? 'Personal',
      isPinned: json['isPinned'] as bool? ?? false,
      reminderId: json['reminderId'] as int?,
      reminderDateTime: json['reminderDateTime'] != null
          ? DateTime.tryParse(json['reminderDateTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
