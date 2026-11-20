class UserProfile {
  final String name;
  final int age;
  final String sex;
  final double heightCm;
  final double currentWeightKg;

  // Baseline / Current measurements (cm)
  final double? chestCm;
  final double? waistCm;
  final double? shoulderCm;
  final double? bicepsCm;
  final double? forearmCm;
  final double? thighCm;
  final double? calfCm;
  final double? neckCm;

  // Fitness Goal
  final String
  fitnessGoal; // muscle_gain, fat_loss, recomposition, general_fitness
  final String targetPhysiqueDescription;

  // Ideal target measurements (cm)
  final double? targetWeightKg;
  final double? targetWaistCm;
  final double? targetChestCm;
  final double? targetBicepsCm;
  final double? targetShoulderCm;
  final double? targetThighCm;
  final double? targetCalfCm;
  final double? targetForearmCm;
  final double? targetNeckCm;

  const UserProfile({
    required this.name,
    this.age = 20,
    this.sex = 'Male',
    this.heightCm = 175.0,
    this.currentWeightKg = 75.0,
    this.chestCm,
    this.waistCm,
    this.shoulderCm,
    this.bicepsCm,
    this.forearmCm,
    this.thighCm,
    this.calfCm,
    this.neckCm,
    this.fitnessGoal = 'recomposition',
    this.targetPhysiqueDescription = '',
    this.targetWeightKg,
    this.targetWaistCm,
    this.targetChestCm,
    this.targetBicepsCm,
    this.targetShoulderCm,
    this.targetThighCm,
    this.targetCalfCm,
    this.targetForearmCm,
    this.targetNeckCm,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? sex,
    double? heightCm,
    double? currentWeightKg,
    double? chestCm,
    double? waistCm,
    double? shoulderCm,
    double? bicepsCm,
    double? forearmCm,
    double? thighCm,
    double? calfCm,
    double? neckCm,
    String? fitnessGoal,
    String? targetPhysiqueDescription,
    double? targetWeightKg,
    double? targetWaistCm,
    double? targetChestCm,
    double? targetBicepsCm,
    double? targetShoulderCm,
    double? targetThighCm,
    double? targetCalfCm,
    double? targetForearmCm,
    double? targetNeckCm,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      shoulderCm: shoulderCm ?? this.shoulderCm,
      bicepsCm: bicepsCm ?? this.bicepsCm,
      forearmCm: forearmCm ?? this.forearmCm,
      thighCm: thighCm ?? this.thighCm,
      calfCm: calfCm ?? this.calfCm,
      neckCm: neckCm ?? this.neckCm,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      targetPhysiqueDescription:
          targetPhysiqueDescription ?? this.targetPhysiqueDescription,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetWaistCm: targetWaistCm ?? this.targetWaistCm,
      targetChestCm: targetChestCm ?? this.targetChestCm,
      targetBicepsCm: targetBicepsCm ?? this.targetBicepsCm,
      targetShoulderCm: targetShoulderCm ?? this.targetShoulderCm,
      targetThighCm: targetThighCm ?? this.targetThighCm,
      targetCalfCm: targetCalfCm ?? this.targetCalfCm,
      targetForearmCm: targetForearmCm ?? this.targetForearmCm,
      targetNeckCm: targetNeckCm ?? this.targetNeckCm,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'shoulderCm': shoulderCm,
      'bicepsCm': bicepsCm,
      'forearmCm': forearmCm,
      'thighCm': thighCm,
      'calfCm': calfCm,
      'neckCm': neckCm,
      'fitnessGoal': fitnessGoal,
      'targetPhysiqueDescription': targetPhysiqueDescription,
      'targetWeightKg': targetWeightKg,
      'targetWaistCm': targetWaistCm,
      'targetChestCm': targetChestCm,
      'targetBicepsCm': targetBicepsCm,
      'targetShoulderCm': targetShoulderCm,
      'targetThighCm': targetThighCm,
      'targetCalfCm': targetCalfCm,
      'targetForearmCm': targetForearmCm,
      'targetNeckCm': targetNeckCm,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'Athlete',
      age: (json['age'] as num?)?.toInt() ?? 20,
      sex: json['sex'] as String? ?? 'Male',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 175.0,
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble() ?? 75.0,
      chestCm: (json['chestCm'] as num?)?.toDouble(),
      waistCm: (json['waistCm'] as num?)?.toDouble(),
      shoulderCm: (json['shoulderCm'] as num?)?.toDouble(),
      bicepsCm: (json['bicepsCm'] as num?)?.toDouble(),
      forearmCm: (json['forearmCm'] as num?)?.toDouble(),
      thighCm: (json['thighCm'] as num?)?.toDouble(),
      calfCm: (json['calfCm'] as num?)?.toDouble(),
      neckCm: (json['neckCm'] as num?)?.toDouble(),
      fitnessGoal: json['fitnessGoal'] as String? ?? 'recomposition',
      targetPhysiqueDescription:
          json['targetPhysiqueDescription'] as String? ?? '',
      targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
      targetWaistCm: (json['targetWaistCm'] as num?)?.toDouble(),
      targetChestCm: (json['targetChestCm'] as num?)?.toDouble(),
      targetBicepsCm: (json['targetBicepsCm'] as num?)?.toDouble(),
      targetShoulderCm: (json['targetShoulderCm'] as num?)?.toDouble(),
      targetThighCm: (json['targetThighCm'] as num?)?.toDouble(),
      targetCalfCm: (json['targetCalfCm'] as num?)?.toDouble(),
      targetForearmCm: (json['targetForearmCm'] as num?)?.toDouble(),
      targetNeckCm: (json['targetNeckCm'] as num?)?.toDouble(),
    );
  }
}
