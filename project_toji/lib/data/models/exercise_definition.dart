class ExerciseDefinition {
  final String id;
  final String name;
  final String muscleGroup; // Chest, Back, Shoulders, Biceps, Triceps, Forearms, Legs, Calves, Core
  final bool isCustom;
  final int defaultSets;
  final String defaultReps;
  final int defaultRestSeconds;
  final String instructions;

  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.isCustom = false,
    this.defaultSets = 3,
    this.defaultReps = '8-12',
    this.defaultRestSeconds = 90,
    this.instructions = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'isCustom': isCustom,
      'defaultSets': defaultSets,
      'defaultReps': defaultReps,
      'defaultRestSeconds': defaultRestSeconds,
      'instructions': instructions,
    };
  }

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    return ExerciseDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      defaultSets: (json['defaultSets'] as num?)?.toInt() ?? 3,
      defaultReps: json['defaultReps'] as String? ?? '8-12',
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 90,
      instructions: json['instructions'] as String? ?? '',
    );
  }

  ExerciseDefinition copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    bool? isCustom,
    int? defaultSets,
    String? defaultReps,
    int? defaultRestSeconds,
    String? instructions,
  }) {
    return ExerciseDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      isCustom: isCustom ?? this.isCustom,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      instructions: instructions ?? this.instructions,
    );
  }
}

class MuscleGroups {
  static const String chest = 'Chest';
  static const String back = 'Back';
  static const String shoulders = 'Shoulders';
  static const String biceps = 'Biceps';
  static const String triceps = 'Triceps';
  static const String forearms = 'Forearms';
  static const String legs = 'Legs';
  static const String calves = 'Calves';
  static const String core = 'Core';

  static const List<String> all = [
    chest,
    back,
    shoulders,
    biceps,
    triceps,
    forearms,
    legs,
    calves,
    core,
  ];
}

