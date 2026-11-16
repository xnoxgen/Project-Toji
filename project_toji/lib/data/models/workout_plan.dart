class PlannedExercise {
  final String id;
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final int targetSets;
  final String targetReps;
  final int restSeconds;
  final String notes;
  final int orderIndex;

  const PlannedExercise({
    required this.id,
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    this.targetSets = 3,
    this.targetReps = '8-12',
    this.restSeconds = 90,
    this.notes = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'name': name,
      'muscleGroup': muscleGroup,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'restSeconds': restSeconds,
      'notes': notes,
      'orderIndex': orderIndex,
    };
  }

  factory PlannedExercise.fromJson(Map<String, dynamic> json) {
    return PlannedExercise(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String? ?? 'General',
      targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
      targetReps: json['targetReps'] as String? ?? '8-12',
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 90,
      notes: json['notes'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }

  PlannedExercise copyWith({
    String? id,
    String? exerciseId,
    String? name,
    String? muscleGroup,
    int? targetSets,
    String? targetReps,
    int? restSeconds,
    String? notes,
    int? orderIndex,
  }) {
    return PlannedExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

class DayWorkoutPlan {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String dayName;
  final String focusName;
  final bool isRestDay;
  final List<PlannedExercise> exercises;

  const DayWorkoutPlan({
    required this.dayOfWeek,
    required this.dayName,
    this.focusName = '',
    this.isRestDay = false,
    this.exercises = const [],
  });

  DayWorkoutPlan copyWith({
    int? dayOfWeek,
    String? dayName,
    String? focusName,
    bool? isRestDay,
    List<PlannedExercise>? exercises,
  }) {
    return DayWorkoutPlan(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      focusName: focusName ?? this.focusName,
      isRestDay: isRestDay ?? this.isRestDay,
      exercises: exercises ?? List.from(this.exercises),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'focusName': focusName,
      'isRestDay': isRestDay,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory DayWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return DayWorkoutPlan(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      dayName: json['dayName'] as String,
      focusName: json['focusName'] as String? ?? '',
      isRestDay: json['isRestDay'] as bool? ?? false,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

