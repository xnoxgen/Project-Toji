import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';
import '../models/reminder_model.dart';

class NotesStorageService {
  static const String _keyNotes = 'project_toji_notes_v1';
  static const String _keyReminders = 'project_toji_reminders_v1';

  final SharedPreferences _prefs;

  NotesStorageService(this._prefs);

  static Future<NotesStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return NotesStorageService(prefs);
  }

  // Load Notes
  List<NoteModel> loadNotes() {
    final raw = _prefs.getString(_keyNotes);

    if (raw == null) {
      return _defaultNotes();
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;

      return list
          .map((item) => NoteModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading notes: $e');
      return _defaultNotes();
    }
  }

  // Save Notes
  Future<void> saveNotes(List<NoteModel> notes) async {
    final encoded = jsonEncode(notes.map((n) => n.toJson()).toList());
    await _prefs.setString(_keyNotes, encoded);
  }

  // Load Reminders
  List<ReminderModel> loadReminders() {
    final raw = _prefs.getString(_keyReminders);

    if (raw == null) {
      return _defaultReminders();
    }

    try {
      final list = jsonDecode(raw) as List<dynamic>;

      return list
          .map((item) => ReminderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      return _defaultReminders();
    }
  }

  // Save Reminders
  Future<void> saveReminders(List<ReminderModel> reminders) async {
    final encoded = jsonEncode(reminders.map((r) => r.toJson()).toList());
    await _prefs.setString(_keyReminders, encoded);
  }

  // Sample Starter Notes with Rich Text & Labels
  List<NoteModel> _defaultNotes() {
    final now = DateTime.now();
    return [
      NoteModel(
        id: 'default_note_1',
        title: 'Project Toji — Philosophy & Rules',
        content:
            '1. Discipline beats motivation every single day.\n'
            '2. Progressive overload on compound lifts.\n'
            '3. Prioritize protein and restorative sleep.\n'
            '4. Track workouts and body metrics relentlessly.',
        labelIds: const ['label_important', 'label_personal'],
        category: 'Gym',
        isPinned: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      NoteModel(
        id: 'default_note_2',
        title: 'Weekly Meal Prep Strategy',
        content:
            '• Chicken breast: 2.5 kg grilled with lemon herb seasoning\n'
            '• Jasmine rice: 1 kg dry weighed into 5 containers\n'
            '• Steamed broccoli and asparagus for micronutrients\n'
            '• Electrolytes and 4 liters of water daily.',
        labelIds: const ['label_todo', 'label_personal'],
        category: 'Personal',
        isPinned: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      NoteModel(
        id: 'default_note_3',
        title: 'Semester Study Timetable',
        content:
            'Monday & Wednesday: Discrete Mathematics and Data Structures.\n'
            'Tuesday & Thursday: Operating Systems and Algorithms lab.\n'
            'Friday: Project revision and paper reading.',
        labelIds: const ['label_study', 'label_work'],
        category: 'College',
        isPinned: false,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  // Sample Starter Reminders
  List<ReminderModel> _defaultReminders() {
    final now = DateTime.now();
    return [
      ReminderModel(
        id: 101,
        title: 'Post-Workout Protein & Creatine',
        description: 'Drink 40g whey isolate with 5g creatine monohydrate within 45 mins.',
        dateTime: DateTime(now.year, now.month, now.day, 19, 30),
        priority: 'high',
        isCompleted: false,
        isNotificationEnabled: true,
        advanceMinutes: 10,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      ReminderModel(
        id: 102,
        title: 'Mobility & Hip Flexor Stretching',
        description:
            '15 minutes of foam rolling and deep pigeon stretch before bed.',
        dateTime: DateTime(now.year, now.month, now.day, 21, 30),
        priority: 'medium',
        isCompleted: false,
        isNotificationEnabled: true,
        advanceMinutes: 15,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ];
  }
}
