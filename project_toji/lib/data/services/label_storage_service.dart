import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/label_model.dart';

class LabelStorageService {
  static const String _keyLabels = 'project_toji_labels_v1';

  final SharedPreferences _prefs;

  LabelStorageService(this._prefs);

  static Future<LabelStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LabelStorageService(prefs);
  }

  List<LabelModel> loadLabels() {
    final raw = _prefs.getString(_keyLabels);
    if (raw == null) {
      return defaultLabels();
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((item) => LabelModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading labels: $e');
      return defaultLabels();
    }
  }

  Future<void> saveLabels(List<LabelModel> labels) async {
    final encoded = jsonEncode(labels.map((l) => l.toJson()).toList());
    await _prefs.setString(_keyLabels, encoded);
  }

  static List<LabelModel> defaultLabels() {
    final now = DateTime.now();
    return [
      LabelModel(
        id: 'label_personal',
        name: 'Personal',
        colorValue: 0xFF10B981, // Emerald Green
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabelModel(
        id: 'label_work',
        name: 'Work',
        colorValue: 0xFFF59E0B, // Amber
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabelModel(
        id: 'label_study',
        name: 'Study',
        colorValue: 0xFF3B82F6, // Blue
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabelModel(
        id: 'label_ideas',
        name: 'Ideas',
        colorValue: 0xFF8B5CF6, // Purple
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabelModel(
        id: 'label_important',
        name: 'Important',
        colorValue: 0xFFDC143C, // Crimson Red
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      LabelModel(
        id: 'label_todo',
        name: 'To-Do',
        colorValue: 0xFF06B6D4, // Cyan
        createdAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
