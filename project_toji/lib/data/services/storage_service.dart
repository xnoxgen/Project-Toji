import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../models/body_measurement.dart';
import '../models/workout_plan.dart';
import '../models/exercise_definition.dart';
import '../models/workout_session.dart';
import '../models/weekly_checkin.dart';

class StorageService {
  static const String _keyProfile = 'physique_user_profile';
  static const String _keySettings = 'physique_app_settings';
  static const String _keyMeasurements = 'physique_body_measurements';
  static const String _keyPlans = 'physique_weekly_plans';
  static const String _keyCustomExercises = 'physique_custom_exercises';
  static const String _keySessions = 'physique_workout_sessions';
  static const String _keyCheckins = 'physique_weekly_checkins';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // User Profile
  UserProfile? loadUserProfile() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // App Settings
  AppSettings loadAppSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // Body Measurements
  List<BodyMeasurement> loadMeasurements() {
    final raw = _prefs.getString(_keyMeasurements);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => BodyMeasurement.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveMeasurements(List<BodyMeasurement> measurements) async {
    final encoded = jsonEncode(measurements.map((m) => m.toJson()).toList());
    await _prefs.setString(_keyMeasurements, encoded);
  }

  // Weekly Workout Plans
  Map<int, DayWorkoutPlan>? loadWeeklyPlans() {
    final raw = _prefs.getString(_keyPlans);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final result = <int, DayWorkoutPlan>{};
      map.forEach((key, value) {
        final day = int.tryParse(key);
        if (day != null) {
          result[day] = DayWorkoutPlan.fromJson(value as Map<String, dynamic>);
        }
      });
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWeeklyPlans(Map<int, DayWorkoutPlan> plans) async {
    final map = <String, dynamic>{};
    plans.forEach((key, value) {
      map[key.toString()] = value.toJson();
    });
    await _prefs.setString(_keyPlans, jsonEncode(map));
  }

  // Custom Exercises
  List<ExerciseDefinition> loadCustomExercises() {
    final raw = _prefs.getString(_keyCustomExercises);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (item) => ExerciseDefinition.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCustomExercises(List<ExerciseDefinition> exercises) async {
    final encoded = jsonEncode(exercises.map((e) => e.toJson()).toList());
    await _prefs.setString(_keyCustomExercises, encoded);
  }

  // Workout Sessions
  List<WorkoutSession> loadWorkoutSessions() {
    final raw = _prefs.getString(_keySessions);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => WorkoutSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkoutSessions(List<WorkoutSession> sessions) async {
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await _prefs.setString(_keySessions, encoded);
  }

  // Weekly Check-Ins
  List<WeeklyCheckIn> loadWeeklyCheckins() {
    final raw = _prefs.getString(_keyCheckins);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => WeeklyCheckIn.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWeeklyCheckins(List<WeeklyCheckIn> checkins) async {
    final encoded = jsonEncode(checkins.map((c) => c.toJson()).toList());
    await _prefs.setString(_keyCheckins, encoded);
  }

  // Full Database Backup (Export JSON)
  String exportFullBackupJson() {
    final backup = {
      'version': '1.0.0',
      'appName': 'PHYSIQUE',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': loadUserProfile()?.toJson(),
      'settings': loadAppSettings().toJson(),
      'measurements': loadMeasurements().map((m) => m.toJson()).toList(),
      'plans': loadWeeklyPlans()?.map(
        (k, v) => MapEntry(k.toString(), v.toJson()),
      ),
      'customExercises': loadCustomExercises().map((e) => e.toJson()).toList(),
      'sessions': loadWorkoutSessions().map((s) => s.toJson()).toList(),
      'checkins': loadWeeklyCheckins().map((c) => c.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  // Restore Database from JSON
  Future<bool> importFullBackupJson(String rawJson) async {
    try {
      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return false;

      if (decoded['profile'] != null) {
        await _prefs.setString(_keyProfile, jsonEncode(decoded['profile']));
      }
      if (decoded['settings'] != null) {
        await _prefs.setString(_keySettings, jsonEncode(decoded['settings']));
      }
      if (decoded['measurements'] != null) {
        await _prefs.setString(
          _keyMeasurements,
          jsonEncode(decoded['measurements']),
        );
      }
      if (decoded['plans'] != null) {
        await _prefs.setString(_keyPlans, jsonEncode(decoded['plans']));
      }
      if (decoded['customExercises'] != null) {
        await _prefs.setString(
          _keyCustomExercises,
          jsonEncode(decoded['customExercises']),
        );
      }
      if (decoded['sessions'] != null) {
        await _prefs.setString(_keySessions, jsonEncode(decoded['sessions']));
      }
      if (decoded['checkins'] != null) {
        await _prefs.setString(_keyCheckins, jsonEncode(decoded['checkins']));
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear / Reset All Data
  Future<void> clearAllData() async {
    await _prefs.remove(_keyProfile);
    await _prefs.remove(_keySettings);
    await _prefs.remove(_keyMeasurements);
    await _prefs.remove(_keyPlans);
    await _prefs.remove(_keyCustomExercises);
    await _prefs.remove(_keySessions);
    await _prefs.remove(_keyCheckins);
  }
}
