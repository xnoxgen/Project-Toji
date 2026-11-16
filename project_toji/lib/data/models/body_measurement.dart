class BodyMeasurement {
  final String id;
  final DateTime date;
  final String metricType; // weight, waist, chest, biceps, forearms, thighs, calves, shoulders, neck
  final double value;
  final String unit; // kg, cm
  final String? notes;

  const BodyMeasurement({
    required this.id,
    required this.date,
    required this.metricType,
    required this.value,
    this.unit = 'cm',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'metricType': metricType,
      'value': value,
      'unit': unit,
      'notes': notes,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      metricType: json['metricType'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'cm',
      notes: json['notes'] as String?,
    );
  }

  BodyMeasurement copyWith({
    String? id,
    DateTime? date,
    String? metricType,
    double? value,
    String? unit,
    String? notes,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      date: date ?? this.date,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }
}

