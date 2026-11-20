class SetLog {
  final int setNumber;
  final String targetReps;
  final int actualReps;
  final double weightKg;
  final bool isCompleted;

  const SetLog({
    required this.setNumber,
    this.targetReps = '8-12',
    this.actualReps = 10,
    this.weightKg = 0.0,
    this.isCompleted = false,
  });

  SetLog copyWith({
    int? setNumber,
    String? targetReps,
    int? actualReps,
    double? weightKg,
    bool? isCompleted,
  }) {
    return SetLog(
      setNumber: setNumber ?? this.setNumber,
      targetReps: targetReps ?? this.targetReps,
      actualReps: actualReps ?? this.actualReps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'targetReps': targetReps,
      'actualReps': actualReps,
      'weightKg': weightKg,
      'isCompleted': isCompleted,
    };
  }

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: (json['setNumber'] as num?)?.toInt() ?? 1,
      targetReps: json['targetReps'] as String? ?? '8-12',
      actualReps: (json['actualReps'] as num?)?.toInt() ?? 10,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class SessionExerciseLog {
  final String exerciseId;
  final String name;
  final String muscleGroup;
  final int targetSets;
  final String targetReps;
  final bool isCompleted;
  final List<SetLog> sets;
  final String notes;

  const SessionExerciseLog({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    this.targetSets = 3,
    this.targetReps = '8-12',
    this.isCompleted = false,
    this.sets = const [],
    this.notes = '',
  });

  SessionExerciseLog copyWith({
    String? exerciseId,
    String? name,
    String? muscleGroup,
    int? targetSets,
    String? targetReps,
    bool? isCompleted,
    List<SetLog>? sets,
    String? notes,
  }) {
    return SessionExerciseLog(
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      isCompleted: isCompleted ?? this.isCompleted,
      sets: sets ?? List.from(this.sets),
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'muscleGroup': muscleGroup,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'isCompleted': isCompleted,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory SessionExerciseLog.fromJson(Map<String, dynamic> json) {
    return SessionExerciseLog(
      exerciseId: json['exerciseId'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String? ?? 'General',
      targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
      targetReps: json['targetReps'] as String? ?? '8-12',
      isCompleted: json['isCompleted'] as bool? ?? false,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((s) => SetLog.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
    );
  }
}

class WorkoutSession {
  final String id;
  final DateTime date;
  final int dayOfWeek;
  final String workoutName;
  final bool isCompleted;
  final List<SessionExerciseLog> exercises;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const WorkoutSession({
    required this.id,
    required this.date,
    required this.dayOfWeek,
    required this.workoutName,
    this.isCompleted = false,
    this.exercises = const [],
    this.startedAt,
    this.completedAt,
  });

  int get completedExercisesCount =>
      exercises.where((e) => e.isCompleted).length;

  int get totalExercisesCount => exercises.length;

  double get completionPercentage {
    if (exercises.isEmpty) return 0.0;
    return (completedExercisesCount / totalExercisesCount) * 100.0;
  }

  int get totalCompletedSets {
    int count = 0;
    for (final exercise in exercises) {
      count += exercise.sets.where((s) => s.isCompleted).length;
    }
    return count;
  }

  double get totalVolumeKg {
    double volume = 0.0;
    for (final exercise in exercises) {
      for (final s in exercise.sets) {
        if (s.isCompleted) {
          volume += (s.weightKg * s.actualReps);
        }
      }
    }
    return volume;
  }

  WorkoutSession copyWith({
    String? id,
    DateTime? date,
    int? dayOfWeek,
    String? workoutName,
    bool? isCompleted,
    List<SessionExerciseLog>? exercises,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      date: date ?? this.date,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      workoutName: workoutName ?? this.workoutName,
      isCompleted: isCompleted ?? this.isCompleted,
      exercises: exercises ?? List.from(this.exercises),
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'workoutName': workoutName,
      'isCompleted': isCompleted,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      workoutName: json['workoutName'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map(
                (e) => SessionExerciseLog.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
