class WeeklyCheckIn {
  final String id;
  final DateTime date;
  final double weightKg;
  final double? waistCm;
  final double? chestCm;
  final double? bicepsCm;
  final double? thighsCm;
  final double? forearmsCm;
  final double? calvesCm;
  final double? neckCm;
  final int workoutConsistencyRating; // 1-5
  final int energyRecoveryRating; // 1-5
  final String notes;

  const WeeklyCheckIn({
    required this.id,
    required this.date,
    required this.weightKg,
    this.waistCm,
    this.chestCm,
    this.bicepsCm,
    this.thighsCm,
    this.forearmsCm,
    this.calvesCm,
    this.neckCm,
    this.workoutConsistencyRating = 4,
    this.energyRecoveryRating = 4,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'bicepsCm': bicepsCm,
      'thighsCm': thighsCm,
      'forearmsCm': forearmsCm,
      'calvesCm': calvesCm,
      'neckCm': neckCm,
      'workoutConsistencyRating': workoutConsistencyRating,
      'energyRecoveryRating': energyRecoveryRating,
      'notes': notes,
    };
  }

  factory WeeklyCheckIn.fromJson(Map<String, dynamic> json) {
    return WeeklyCheckIn(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      bicepsCm: (json['bicepsCm'] as num?)?.toDouble(),
      thighsCm: (json['thighsCm'] as num?)?.toDouble(),
      forearmsCm: (json['forearmsCm'] as num?)?.toDouble(),
      calvesCm: (json['calvesCm'] as num?)?.toDouble(),
      neckCm: (json['neckCm'] as num?)?.toDouble(),
      workoutConsistencyRating:
          (json['workoutConsistencyRating'] as num?)?.toInt() ?? 4,
      energyRecoveryRating:
          (json['energyRecoveryRating'] as num?)?.toInt() ?? 4,
      notes: json['notes'] as String? ?? '',
    );
  }

  WeeklyCheckIn copyWith({
    String? id,
    DateTime? date,
    double? weightKg,
    double? waistCm,
    double? chestCm,
    double? bicepsCm,
    double? thighsCm,
    double? forearmsCm,
    double? calvesCm,
    double? neckCm,
    int? workoutConsistencyRating,
    int? energyRecoveryRating,
    String? notes,
  }) {
    return WeeklyCheckIn(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      bicepsCm: bicepsCm ?? this.bicepsCm,
      thighsCm: thighsCm ?? this.thighsCm,
      forearmsCm: forearmsCm ?? this.forearmsCm,
      calvesCm: calvesCm ?? this.calvesCm,
      neckCm: neckCm ?? this.neckCm,
      workoutConsistencyRating:
          workoutConsistencyRating ?? this.workoutConsistencyRating,
      energyRecoveryRating: energyRecoveryRating ?? this.energyRecoveryRating,
      notes: notes ?? this.notes,
    );
  }
}
