class ReminderModel {
  final int id; // Notification ID
  final String title;
  final String? description;
  final DateTime dateTime;
  final String priority; // 'high', 'medium', 'low'
  final bool isCompleted;
  final bool isNotificationEnabled; // Notification toggle
  final int advanceMinutes; // 0 = at time, 5, 10, 15, or custom minutes before
  final String? noteId; // Associated note ID
  final String? noteTitle; // Associated note title
  final DateTime createdAt;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.priority = 'medium',
    this.isCompleted = false,
    this.isNotificationEnabled = true,
    this.advanceMinutes = 0,
    this.noteId,
    this.noteTitle,
    required this.createdAt,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    return dateTime.isBefore(DateTime.now());
  }

  // Calculated advance notification time
  DateTime get advanceDateTime {
    if (advanceMinutes <= 0) return dateTime;
    return dateTime.subtract(Duration(minutes: advanceMinutes));
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? priority,
    bool? isCompleted,
    bool? isNotificationEnabled,
    int? advanceMinutes,
    String? noteId,
    String? noteTitle,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      advanceMinutes: advanceMinutes ?? this.advanceMinutes,
      noteId: noteId ?? this.noteId,
      noteTitle: noteTitle ?? this.noteTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'isNotificationEnabled': isNotificationEnabled,
      'advanceMinutes': advanceMinutes,
      'noteId': noteId,
      'noteTitle': noteTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.tryParse(json['dateTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      priority: json['priority'] as String? ?? 'medium',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
      advanceMinutes: json['advanceMinutes'] as int? ?? 0,
      noteId: json['noteId'] as String?,
      noteTitle: json['noteTitle'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
