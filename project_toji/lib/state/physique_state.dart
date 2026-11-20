import 'package:flutter/material.dart';

import '../data/models/user_profile.dart';
import '../data/models/app_settings.dart';
import '../data/models/body_measurement.dart';
import '../data/models/workout_plan.dart';
import '../data/models/exercise_definition.dart';
import '../data/models/workout_session.dart';
import '../data/models/weekly_checkin.dart';
import '../data/repositories/default_data.dart';
import '../data/services/storage_service.dart';

class PhysiqueState extends ChangeNotifier {
  final StorageService _storage;

  late UserProfile _profile;
  late AppSettings _settings;
  late Map<int, DayWorkoutPlan> _weeklyPlans;
  late List<ExerciseDefinition> _customExercises;
  late List<BodyMeasurement> _measurements;
  late List<WorkoutSession> _sessions;
  late List<WeeklyCheckIn> _checkins;

  PhysiqueState(this._storage) {
    _loadFromStorage();
  }

  // Getters
  UserProfile get profile => _profile;
  AppSettings get settings => _settings;
  Map<int, DayWorkoutPlan> get weeklyPlans => _weeklyPlans;
  List<ExerciseDefinition> get customExercises => _customExercises;
  List<BodyMeasurement> get measurements => _measurements;
  List<WorkoutSession> get sessions => _sessions;
  List<WeeklyCheckIn> get checkins => _checkins;

  bool get isDarkMode => _settings.themeMode == 'dark';

  List<ExerciseDefinition> get allExercises {
    return [...DefaultData.exerciseLibrary, ..._customExercises];
  }

  void _loadFromStorage() {
    _profile = _storage.loadUserProfile() ?? DefaultData.defaultProfile;
    _settings = _storage.loadAppSettings();
    _weeklyPlans =
        _storage.loadWeeklyPlans() ?? DefaultData.createInitialWeeklyPlan();
    _customExercises = _storage.loadCustomExercises();
    _measurements = _storage.loadMeasurements();
    _sessions = _storage.loadWorkoutSessions();
    _checkins = _storage.loadWeeklyCheckins();

    // If initial launch and no measurements exist, seed baseline measurements from profile
    if (_measurements.isEmpty) {
      _seedBaselineMeasurements();
    }
  }

  void _seedBaselineMeasurements() {
    final now = DateTime.now();
    final initial = <BodyMeasurement>[
      BodyMeasurement(
        id: 'init_weight',
        date: now.subtract(const Duration(days: 7)),
        metricType: 'weight',
        value: _profile.currentWeightKg,
        unit: 'kg',
      ),
    ];
    if (_profile.waistCm != null) {
      initial.add(
        BodyMeasurement(
          id: 'init_waist',
          date: now.subtract(const Duration(days: 7)),
          metricType: 'waist',
          value: _profile.waistCm!,
          unit: 'cm',
        ),
      );
    }
    if (_profile.chestCm != null) {
      initial.add(
        BodyMeasurement(
          id: 'init_chest',
          date: now.subtract(const Duration(days: 7)),
          metricType: 'chest',
          value: _profile.chestCm!,
          unit: 'cm',
        ),
      );
    }
    if (_profile.bicepsCm != null) {
      initial.add(
        BodyMeasurement(
          id: 'init_biceps',
          date: now.subtract(const Duration(days: 7)),
          metricType: 'biceps',
          value: _profile.bicepsCm!,
          unit: 'cm',
        ),
      );
    }
    _measurements = initial;
    _storage.saveMeasurements(_measurements);
  }

  // --- Profile & Onboarding ---
  Future<void> completeOnboarding(UserProfile newProfile) async {
    _profile = newProfile;
    _settings = _settings.copyWith(hasCompletedOnboarding: true);
    await _storage.saveUserProfile(_profile);
    await _storage.saveAppSettings(_settings);

    // Save baseline measurements with current timestamp
    _recordProfileMeasurements(newProfile);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _storage.saveUserProfile(_profile);
    _recordProfileMeasurements(newProfile);
    notifyListeners();
  }

  void _recordProfileMeasurements(UserProfile prof) {
    final now = DateTime.now();
    addMeasurement('weight', prof.currentWeightKg, date: now);
    if (prof.waistCm != null) addMeasurement('waist', prof.waistCm!, date: now);
    if (prof.chestCm != null) {
      addMeasurement('chest', prof.chestCm!, date: now);
    }
    if (prof.bicepsCm != null) {
      addMeasurement('biceps', prof.bicepsCm!, date: now);
    }
    if (prof.shoulderCm != null) {
      addMeasurement('shoulders', prof.shoulderCm!, date: now);
    }
    if (prof.forearmCm != null) {
      addMeasurement('forearms', prof.forearmCm!, date: now);
    }
    if (prof.thighCm != null) {
      addMeasurement('thighs', prof.thighCm!, date: now);
    }
    if (prof.calfCm != null) {
      addMeasurement('calves', prof.calfCm!, date: now);
    }
    if (prof.neckCm != null) {
      addMeasurement('neck', prof.neckCm!, date: now);
    }
  }

  // --- Settings & Theme ---
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? 'light' : 'dark';
    _settings = _settings.copyWith(themeMode: newMode);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  // --- Workout Planner ---
  DayWorkoutPlan getDayPlan(int dayOfWeek) {
    return _weeklyPlans[dayOfWeek] ??
        DayWorkoutPlan(
          dayOfWeek: dayOfWeek,
          dayName: _getDayName(dayOfWeek),
          focusName: 'Rest',
          isRestDay: true,
          exercises: const [],
        );
  }

  DayWorkoutPlan getTodayPlan() {
    final weekday = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    return getDayPlan(weekday);
  }

  Future<void> updateDayPlan(DayWorkoutPlan plan) async {
    _weeklyPlans[plan.dayOfWeek] = plan;
    await _storage.saveWeeklyPlans(_weeklyPlans);
    notifyListeners();
  }

  Future<void> addExerciseToDay(int dayOfWeek, PlannedExercise exercise) async {
    final current = getDayPlan(dayOfWeek);
    final updatedList = List<PlannedExercise>.from(current.exercises)
      ..add(exercise.copyWith(orderIndex: current.exercises.length));
    final updated = current.copyWith(isRestDay: false, exercises: updatedList);
    await updateDayPlan(updated);
  }

  Future<void> removeExerciseFromDay(
    int dayOfWeek,
    String plannedExerciseId,
  ) async {
    final current = getDayPlan(dayOfWeek);
    final updatedList = current.exercises
        .where((e) => e.id != plannedExerciseId)
        .toList();
    // Re-index
    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(orderIndex: i);
    }
    await updateDayPlan(current.copyWith(exercises: updatedList));
  }

  Future<void> reorderExercises(
    int dayOfWeek,
    int oldIndex,
    int newIndex,
  ) async {
    final current = getDayPlan(dayOfWeek);
    final list = List<PlannedExercise>.from(current.exercises);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }
    await updateDayPlan(current.copyWith(exercises: list));
  }

  Future<void> duplicateExercise(
    int dayOfWeek,
    String plannedExerciseId,
  ) async {
    final current = getDayPlan(dayOfWeek);
    final index = current.exercises.indexKey((e) => e.id == plannedExerciseId);
    if (index == -1) return;
    final original = current.exercises[index];
    final copy = original.copyWith(
      id: '${original.id}_copy_${DateTime.now().millisecondsSinceEpoch}',
      name: '${original.name} (Copy)',
      orderIndex: index + 1,
    );
    final list = List<PlannedExercise>.from(current.exercises);
    list.insert(index + 1, copy);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(orderIndex: i);
    }
    await updateDayPlan(current.copyWith(exercises: list));
  }

  Future<void> updatePlannedExercise(
    int dayOfWeek,
    PlannedExercise exercise,
  ) async {
    final current = getDayPlan(dayOfWeek);
    final list = current.exercises.map((e) {
      return e.id == exercise.id ? exercise : e;
    }).toList();
    await updateDayPlan(current.copyWith(exercises: list));
  }

  Future<void> updateDayFocus(
    int dayOfWeek,
    String focusName,
    bool isRestDay,
  ) async {
    final current = getDayPlan(dayOfWeek);
    await updateDayPlan(
      current.copyWith(focusName: focusName, isRestDay: isRestDay),
    );
  }

  Future<void> addCustomExercise(ExerciseDefinition exercise) async {
    _customExercises.add(exercise);
    await _storage.saveCustomExercises(_customExercises);
    notifyListeners();
  }

  // --- Workout Execution ---
  String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  WorkoutSession getOrCreateTodaySession() {
    final now = DateTime.now();
    return getOrCreateSessionForDate(now);
  }

  WorkoutSession getOrCreateSessionForDate(DateTime date) {
    final key = _dateKey(date);
    final existingIndex = _sessions.indexWhere((s) => _dateKey(s.date) == key);
    if (existingIndex != -1) {
      return _sessions[existingIndex];
    }

    // Create session initialized from day plan
    final dayPlan = getDayPlan(date.weekday);
    final sessionExercises = dayPlan.exercises.map((p) {
      final sets = List.generate(
        p.targetSets,
        (i) => SetLog(
          setNumber: i + 1,
          targetReps: p.targetReps,
          actualReps: _parseAverageReps(p.targetReps),
          weightKg: 0.0,
          isCompleted: false,
        ),
      );
      return SessionExerciseLog(
        exerciseId: p.exerciseId,
        name: p.name,
        muscleGroup: p.muscleGroup,
        targetSets: p.targetSets,
        targetReps: p.targetReps,
        isCompleted: false,
        sets: sets,
        notes: p.notes,
      );
    }).toList();

    final newSession = WorkoutSession(
      id: 'session_$key',
      date: DateTime(date.year, date.month, date.day),
      dayOfWeek: date.weekday,
      workoutName: dayPlan.focusName.isNotEmpty
          ? dayPlan.focusName
          : 'Daily Workout',
      isCompleted: false,
      exercises: sessionExercises,
      startedAt: DateTime.now(),
    );

    _sessions.add(newSession);
    _storage.saveWorkoutSessions(_sessions);
    notifyListeners();
    return newSession;
  }

  int _parseAverageReps(String reps) {
    if (reps.contains('-')) {
      final parts = reps.split('-');
      final a = int.tryParse(parts[0].trim());
      final b = int.tryParse(parts[1].trim());
      if (a != null && b != null) return ((a + b) / 2).round();
    }
    return int.tryParse(reps.replaceAll(RegExp(r'[^0-9]'), '')) ?? 10;
  }

  Future<void> saveSession(WorkoutSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
    } else {
      _sessions.add(session);
    }
    await _storage.saveWorkoutSessions(_sessions);
    notifyListeners();
  }

  Future<void> updateSetLog({
    required String sessionId,
    required String exerciseId,
    required int setIndex,
    required double weight,
    required int actualReps,
    required bool isCompleted,
  }) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _sessions[sessionIndex];

    final exerciseIndex = session.exercises.indexWhere(
      (e) => e.exerciseId == exerciseId,
    );
    if (exerciseIndex == -1) return;
    final exercise = session.exercises[exerciseIndex];

    final sets = List<SetLog>.from(exercise.sets);
    if (setIndex < sets.length) {
      sets[setIndex] = sets[setIndex].copyWith(
        weightKg: weight,
        actualReps: actualReps,
        isCompleted: isCompleted,
      );
    }

    final allSetsCompleted =
        sets.isNotEmpty && sets.every((s) => s.isCompleted);
    final updatedExercise = exercise.copyWith(
      sets: sets,
      isCompleted: allSetsCompleted,
    );

    final exercises = List<SessionExerciseLog>.from(session.exercises);
    exercises[exerciseIndex] = updatedExercise;

    final allExercisesDone =
        exercises.isNotEmpty && exercises.every((e) => e.isCompleted);
    final updatedSession = session.copyWith(
      exercises: exercises,
      isCompleted: allExercisesDone,
      completedAt: allExercisesDone
          ? (session.completedAt ?? DateTime.now())
          : null,
    );

    await saveSession(updatedSession);
  }

  Future<void> markExerciseDone(String sessionId, String exerciseId) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _sessions[sessionIndex];

    final exerciseIndex = session.exercises.indexWhere(
      (e) => e.exerciseId == exerciseId,
    );
    if (exerciseIndex == -1) return;
    final exercise = session.exercises[exerciseIndex];

    // Mark all sets as completed if not already
    final sets = exercise.sets
        .map((s) => s.copyWith(isCompleted: true))
        .toList();
    final updatedExercise = exercise.copyWith(sets: sets, isCompleted: true);

    final exercises = List<SessionExerciseLog>.from(session.exercises);
    exercises[exerciseIndex] = updatedExercise;

    final allDone =
        exercises.isNotEmpty && exercises.every((e) => e.isCompleted);
    final updatedSession = session.copyWith(
      exercises: exercises,
      isCompleted: allDone,
      completedAt: allDone ? (session.completedAt ?? DateTime.now()) : null,
    );

    await saveSession(updatedSession);
  }

  Future<void> undoExerciseCompletion(
    String sessionId,
    String exerciseId,
  ) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _sessions[sessionIndex];

    final exerciseIndex = session.exercises.indexWhere(
      (e) => e.exerciseId == exerciseId,
    );
    if (exerciseIndex == -1) return;
    final exercise = session.exercises[exerciseIndex];

    final sets = exercise.sets
        .map((s) => s.copyWith(isCompleted: false))
        .toList();
    final updatedExercise = exercise.copyWith(sets: sets, isCompleted: false);

    final exercises = List<SessionExerciseLog>.from(session.exercises);
    exercises[exerciseIndex] = updatedExercise;

    final updatedSession = session.copyWith(
      exercises: exercises,
      isCompleted: false,
      completedAt: null,
    );

    await saveSession(updatedSession);
  }

  Future<void> undoWorkoutCompletion(String sessionId) async {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;
    final session = _sessions[sessionIndex];
    final updatedSession = session.copyWith(
      isCompleted: false,
      completedAt: null,
    );
    await saveSession(updatedSession);
  }

  // --- Streaks & Consistency ---
  Set<String> get completedDateKeys {
    final set = <String>{};
    for (final s in _sessions) {
      if (s.isCompleted || s.completedExercisesCount > 0) {
        set.add(_dateKey(s.date));
      }
    }
    return set;
  }

  int get totalWorkoutsCompleted {
    return _sessions.where((s) => s.isCompleted).length;
  }

  int get currentStreak {
    final completedKeys = completedDateKeys;
    if (completedKeys.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    // If today hasn't been completed yet, check if yesterday was completed
    final todayKey = _dateKey(checkDate);
    if (!completedKeys.contains(todayKey)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
      final yesterdayKey = _dateKey(checkDate);
      if (!completedKeys.contains(yesterdayKey)) {
        return 0;
      }
    }

    // Count backwards
    while (completedKeys.contains(_dateKey(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get longestStreak {
    final completedKeys = completedDateKeys;
    if (completedKeys.isEmpty) return 0;

    final sortedDates = completedKeys.map((k) => DateTime.parse(k)).toList()
      ..sort();
    int longest = 1;
    int current = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final diff = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  double get weeklyConsistencyPercentage {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    int plannedDays = 0;
    int completedDays = 0;

    for (int i = 0; i < 7; i++) {
      final day = monday.add(Duration(days: i));
      final dayPlan = getDayPlan(day.weekday);
      if (!dayPlan.isRestDay && dayPlan.exercises.isNotEmpty) {
        plannedDays++;
        if (completedDateKeys.contains(_dateKey(day))) {
          completedDays++;
        }
      }
    }

    if (plannedDays == 0) return 100.0;
    return (completedDays / plannedDays) * 100.0;
  }

  // --- Progress & Analytics ---
  Future<void> addMeasurement(
    String metricType,
    double value, {
    DateTime? date,
    String? notes,
  }) async {
    final entry = BodyMeasurement(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}_$metricType',
      date: date ?? DateTime.now(),
      metricType: metricType,
      value: value,
      unit: metricType == 'weight' ? 'kg' : 'cm',
      notes: notes,
    );
    _measurements.add(entry);
    _measurements.sort((a, b) => a.date.compareTo(b.date));
    await _storage.saveMeasurements(_measurements);

    // Sync latest into profile
    if (metricType == 'weight') {
      _profile = _profile.copyWith(currentWeightKg: value);
      await _storage.saveUserProfile(_profile);
    } else if (metricType == 'waist') {
      _profile = _profile.copyWith(waistCm: value);
      await _storage.saveUserProfile(_profile);
    } else if (metricType == 'chest') {
      _profile = _profile.copyWith(chestCm: value);
      await _storage.saveUserProfile(_profile);
    } else if (metricType == 'biceps') {
      _profile = _profile.copyWith(bicepsCm: value);
      await _storage.saveUserProfile(_profile);
    }

    notifyListeners();
  }

  List<BodyMeasurement> getMeasurementsForMetric(
    String metricType, {
    String period = '30d',
  }) {
    final allForMetric = _measurements
        .where((m) => m.metricType == metricType)
        .toList();
    if (allForMetric.isEmpty) return [];

    final now = DateTime.now();
    DateTime cutoff;
    switch (period) {
      case '7d':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case '3m':
        cutoff = now.subtract(const Duration(days: 90));
        break;
      case '6m':
        cutoff = now.subtract(const Duration(days: 180));
        break;
      case '1y':
        cutoff = now.subtract(const Duration(days: 365));
        break;
      default:
        cutoff = DateTime(2000);
    }

    final filtered = allForMetric
        .where((m) => m.date.isAfter(cutoff) || m.date.isAtSameMomentAs(cutoff))
        .toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered.isNotEmpty ? filtered : allForMetric;
  }

  double? getLatestMeasurement(String metricType) {
    final list = _measurements
        .where((m) => m.metricType == metricType)
        .toList();
    if (list.isEmpty) return null;
    list.sort((a, b) => a.date.compareTo(b.date));
    return list.last.value;
  }

  double? getPreviousMeasurement(String metricType) {
    final list = _measurements
        .where((m) => m.metricType == metricType)
        .toList();
    if (list.length < 2) return null;
    list.sort((a, b) => a.date.compareTo(b.date));
    return list[list.length - 2].value;
  }

  double? getMeasurementDelta(String metricType) {
    final list = _measurements
        .where((m) => m.metricType == metricType)
        .toList();
    if (list.length < 2) return 0.0;
    list.sort((a, b) => a.date.compareTo(b.date));
    return list.last.value - list.first.value;
  }

  double? getTargetForMetric(String metricType) {
    switch (metricType) {
      case 'weight':
        return _profile.targetWeightKg;
      case 'waist':
        return _profile.targetWaistCm;
      case 'chest':
        return _profile.targetChestCm;
      case 'biceps':
        return _profile.targetBicepsCm;
      case 'shoulders':
        return _profile.targetShoulderCm;
      case 'thighs':
        return _profile.targetThighCm;
      case 'calves':
        return _profile.targetCalfCm;
      case 'forearms':
        return _profile.targetForearmCm;
      case 'neck':
        return _profile.targetNeckCm;
      default:
        return null;
    }
  }

  // Exercise strength progression (Max weight recorded per date)
  List<Map<String, dynamic>> getExerciseStrengthProgression(
    String exerciseName, {
    String period = '3m',
  }) {
    final result = <Map<String, dynamic>>[];
    for (final session in _sessions) {
      for (final ex in session.exercises) {
        if (ex.name.toLowerCase() == exerciseName.toLowerCase()) {
          double maxWeight = 0.0;
          for (final s in ex.sets) {
            if (s.isCompleted && s.weightKg > maxWeight) {
              maxWeight = s.weightKg;
            }
          }
          if (maxWeight > 0.0) {
            result.add({'date': session.date, 'weight': maxWeight});
          }
        }
      }
    }
    result.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    return result;
  }

  // --- Weekly Check-In System ---
  bool get isWeeklyCheckInDue {
    final now = DateTime.now();
    // Check if dismissed for today
    if (_settings.dismissedCheckInUntil != null &&
        now.isBefore(_settings.dismissedCheckInUntil!)) {
      return false;
    }

    if (_checkins.isEmpty) {
      // If never checked in, check if at least 5 days since onboarding
      return true;
    }
    final lastCheckin = _checkins.last.date;
    return now.difference(lastCheckin).inDays >= 7;
  }

  Future<void> submitWeeklyCheckIn(WeeklyCheckIn checkin) async {
    _checkins.add(checkin);
    await _storage.saveWeeklyCheckins(_checkins);

    // Save as body measurements too
    final now = checkin.date;
    addMeasurement('weight', checkin.weightKg, date: now);
    if (checkin.waistCm != null) {
      addMeasurement('waist', checkin.waistCm!, date: now);
    }
    if (checkin.chestCm != null) {
      addMeasurement('chest', checkin.chestCm!, date: now);
    }
    if (checkin.bicepsCm != null) {
      addMeasurement('biceps', checkin.bicepsCm!, date: now);
    }
    if (checkin.thighsCm != null) {
      addMeasurement('thighs', checkin.thighsCm!, date: now);
    }
    if (checkin.forearmsCm != null) {
      addMeasurement('forearms', checkin.forearmsCm!, date: now);
    }
    if (checkin.calvesCm != null) {
      addMeasurement('calves', checkin.calvesCm!, date: now);
    }
    if (checkin.neckCm != null) {
      addMeasurement('neck', checkin.neckCm!, date: now);
    }

    _settings = _settings.copyWith(
      lastCheckInDate: now,
      dismissedCheckInUntil: null,
    );
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> dismissCheckInForDays(int days) async {
    final until = DateTime.now().add(Duration(days: days));
    _settings = _settings.copyWith(dismissedCheckInUntil: until);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  // --- Backup & Restore ---
  String exportBackup() => _storage.exportFullBackupJson();

  Future<bool> importBackup(String json) async {
    final ok = await _storage.importFullBackupJson(json);
    if (ok) {
      _loadFromStorage();
      notifyListeners();
    }
    return ok;
  }

  Future<void> resetAllData() async {
    await _storage.clearAllData();
    _loadFromStorage();
    notifyListeners();
  }

  String _getDayName(int dayOfWeek) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) return days[dayOfWeek - 1];
    return 'Day';
  }
}

extension _IterableExt<T> on Iterable<T> {
  int indexKey(bool Function(T) test) {
    int i = 0;
    for (final element in this) {
      if (test(element)) return i;
      i++;
    }
    return -1;
  }
}
