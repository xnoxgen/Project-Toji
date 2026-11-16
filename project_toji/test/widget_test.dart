import 'package:flutter_test/flutter_test.dart';
import 'package:project_toji/data/models/user_profile.dart';
import 'package:project_toji/data/models/workout_session.dart';
import 'package:project_toji/data/repositories/default_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_toji/data/services/storage_service.dart';
import 'package:project_toji/state/physique_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Profile Tests', () {
    test('UserProfile JSON serialization and copyWith', () {
      const profile = UserProfile(
        name: 'Kavya',
        age: 18,
        sex: 'Male',
        heightCm: 188.0,
        currentWeightKg: 80.0,
        waistCm: 91.0,
        chestCm: 96.0,
        fitnessGoal: 'recomposition',
      );

      final json = profile.toJson();
      expect(json['name'], 'Kavya');
      expect(json['heightCm'], 188.0);
      expect(json['waistCm'], 91.0);

      final deserialized = UserProfile.fromJson(json);
      expect(deserialized.name, 'Kavya');
      expect(deserialized.currentWeightKg, 80.0);

      final updated = deserialized.copyWith(currentWeightKg: 79.2);
      expect(updated.currentWeightKg, 79.2);
      expect(updated.name, 'Kavya');
    });
  });

  group('Workout Plan & Session Calculations', () {
    test('Default weekly plan has 7 days and correct structure', () {
      final plans = DefaultData.createInitialWeeklyPlan();
      expect(plans.length, 7);
      expect(plans[1]!.dayName, 'Monday');
      expect(plans[1]!.focusName, 'Upper A');
      expect(plans[1]!.exercises.isNotEmpty, true);
      expect(plans[3]!.isRestDay, true);
    });

    test('WorkoutSession completion percentage and volume calculation', () {
      const ex1 = SessionExerciseLog(
        exerciseId: 'chest_bench_press',
        name: 'Bench Press',
        muscleGroup: 'Chest',
        targetSets: 2,
        isCompleted: true,
        sets: [
          SetLog(setNumber: 1, actualReps: 10, weightKg: 80.0, isCompleted: true),
          SetLog(setNumber: 2, actualReps: 8, weightKg: 80.0, isCompleted: true),
        ],
      );

      const ex2 = SessionExerciseLog(
        exerciseId: 'back_lat_pulldown',
        name: 'Lat Pulldown',
        muscleGroup: 'Back',
        targetSets: 1,
        isCompleted: false,
        sets: [
          SetLog(setNumber: 1, actualReps: 10, weightKg: 60.0, isCompleted: false),
        ],
      );

      final session = WorkoutSession(
        id: 'test_session',
        date: DateTime.now(),
        dayOfWeek: 1,
        workoutName: 'Upper A',
        exercises: [ex1, ex2],
      );

      expect(session.completedExercisesCount, 1);
      expect(session.totalExercisesCount, 2);
      expect(session.completionPercentage, 50.0);
      expect(session.totalCompletedSets, 2);
      // Volume: 10*80 + 8*80 = 800 + 640 = 1440 kg
      expect(session.totalVolumeKg, 1440.0);
    });
  });

  group('State and Persistence Tests', () {
    test('StorageService backup export and import roundtrip', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final state = PhysiqueState(storage);

      expect(state.profile.name.isNotEmpty, true);
      expect(state.weeklyPlans.length, 7);

      // Add a test measurement
      await state.addMeasurement('weight', 80.5);
      expect(state.getLatestMeasurement('weight'), 80.5);

      // Export JSON backup
      final backupJson = state.exportBackup();
      expect(backupJson.contains('PHYSIQUE'), true);
      expect(backupJson.contains('80.5'), true);

      // Reset data
      await state.resetAllData();

      // Restore from backup
      final restored = await state.importBackup(backupJson);
      expect(restored, true);
      expect(state.getLatestMeasurement('weight'), 80.5);
    });

    test('Streak calculation counts consecutive workout days', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final state = PhysiqueState(storage);

      final now = DateTime.now();
      final todaySession = state.getOrCreateSessionForDate(now);
      await state.markExerciseDone(todaySession.id, todaySession.exercises.first.exerciseId);

      expect(state.currentStreak >= 1, true);
    });

    test('Clicking Complete button marks exercise completed and updates session', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final state = PhysiqueState(storage);

      final now = DateTime.now();
      final session = state.getOrCreateSessionForDate(now);
      final firstEx = session.exercises.first;
      expect(firstEx.isCompleted, false);

      // Click complete
      await state.markExerciseDone(session.id, firstEx.exerciseId);
      final updated = state.getOrCreateSessionForDate(now);
      expect(updated.exercises.first.isCompleted, true);
      expect(updated.completedExercisesCount >= 1, true);

      // Undo completion
      await state.undoExerciseCompletion(session.id, firstEx.exerciseId);
      final reverted = state.getOrCreateSessionForDate(now);
      expect(reverted.exercises.first.isCompleted, false);
    });
  });
}
