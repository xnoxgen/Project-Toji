class LabelModel {
  final String id;
  final String name;
  final int colorValue; // ARGB integer
  final DateTime createdAt;

  const LabelModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
  });

  LabelModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return LabelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      colorValue: json['colorValue'] as int? ?? 0xFFDC143C,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Pre-configured default palette for user selection
  static const List<int> defaultColors = [
    0xFFDC143C, // Crimson (Primary Brand)
    0xFFE11D48, // Rose
    0xFFF97316, // Orange
    0xFFF59E0B, // Amber
    0xFF10B981, // Emerald Green
    0xFF06B6D4, // Cyan
    0xFF3B82F6, // Blue
    0xFF6366F1, // Indigo
    0xFF8B5CF6, // Purple
    0xFFEC4899, // Pink
    0xFF64748B, // Slate Grey
    0xFF94A3B8, // Light Grey
  ];
}
