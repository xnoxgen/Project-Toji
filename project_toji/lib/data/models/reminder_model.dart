class ReminderModel {
  final int id; // Used as notification ID
  final String title;
  final String? description;
  final DateTime dateTime;
  final String priority; // 'high', 'medium', 'low'
  final bool isCompleted;
  final DateTime createdAt;

  const ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.priority = 'medium',
    this.isCompleted = false,
    required this.createdAt,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    return dateTime.isBefore(DateTime.now());
  }

  ReminderModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
