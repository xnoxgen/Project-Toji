import 'package:flutter/foundation.dart';

import '../data/models/label_model.dart';
import '../data/models/note_model.dart';
import '../data/models/reminder_model.dart';
import '../data/services/label_storage_service.dart';
import '../data/services/notes_storage_service.dart';
import '../data/services/reminder_notification_service.dart';

class NotesState extends ChangeNotifier {
  final NotesStorageService _storage;
  final LabelStorageService _labelStorage;
  final ReminderNotificationService _notificationService =
      ReminderNotificationService();

  List<NoteModel> _notes = [];
  List<ReminderModel> _reminders = [];
  List<LabelModel> _labels = [];

  String _searchQuery = '';
  final Set<String> _selectedLabelIds = {}; // Empty means "All"
  int _activeModuleTab = 0; // 0 = Notes, 1 = Reminders

  NotesState(this._storage, this._labelStorage) {
    _loadData();
  }

  void _loadData() {
    _notes = _storage.loadNotes();
    _reminders = _storage.loadReminders();
    _labels = _labelStorage.loadLabels();
    notifyListeners();
  }

  // Getters
  List<NoteModel> get notes => List.unmodifiable(_notes);
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  List<LabelModel> get labels => List.unmodifiable(_labels);
  Set<String> get selectedLabelIds => Set.unmodifiable(_selectedLabelIds);
  String get searchQuery => _searchQuery;
  int get activeModuleTab => _activeModuleTab;

  void setActiveModuleTab(int index) {
    if (_activeModuleTab != index) {
      _activeModuleTab = index;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Label Filtering
  void toggleLabelFilter(String labelId) {
    if (_selectedLabelIds.contains(labelId)) {
      _selectedLabelIds.remove(labelId);
    } else {
      _selectedLabelIds.add(labelId);
    }
    notifyListeners();
  }

  void selectSingleLabelFilter(String? labelId) {
    _selectedLabelIds.clear();
    if (labelId != null) {
      _selectedLabelIds.add(labelId);
    }
    notifyListeners();
  }

  void clearLabelFilters() {
    _selectedLabelIds.clear();
    notifyListeners();
  }

  LabelModel? getLabelById(String id) {
    try {
      return _labels.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  // Label Management
  bool isLabelNameDuplicate(String name, {String? excludeId}) {
    final trimmed = name.trim().toLowerCase();
    return _labels.any(
      (l) => l.name.trim().toLowerCase() == trimmed && l.id != excludeId,
    );
  }

  Future<bool> addLabel(String name, int colorValue) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || isLabelNameDuplicate(trimmed)) {
      return false;
    }

    final newLabel = LabelModel(
      id: 'label_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
      colorValue: colorValue,
      createdAt: DateTime.now(),
    );

    _labels.add(newLabel);
    await _labelStorage.saveLabels(_labels);
    notifyListeners();
    return true;
  }

  Future<bool> updateLabel(LabelModel updated) async {
    final index = _labels.indexWhere((l) => l.id == updated.id);
    if (index == -1) return false;

    if (isLabelNameDuplicate(updated.name, excludeId: updated.id)) {
      return false;
    }

    _labels[index] = updated;
    await _labelStorage.saveLabels(_labels);
    notifyListeners();
    return true;
  }

  Future<void> deleteLabel(String labelId) async {
    // 1. Remove label from list
    _labels.removeWhere((l) => l.id == labelId);
    _selectedLabelIds.remove(labelId);
    await _labelStorage.saveLabels(_labels);

    // 2. Remove association from all existing notes without deleting the notes
    bool notesModified = false;
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].labelIds.contains(labelId)) {
        final updatedIds = List<String>.from(_notes[i].labelIds)
          ..remove(labelId);
        _notes[i] = _notes[i].copyWith(labelIds: updatedIds);
        notesModified = true;
      }
    }

    if (notesModified) {
      await _storage.saveNotes(_notes);
    }

    notifyListeners();
  }

  // Notes filtering
  List<NoteModel> get filteredNotes {
    var result = List<NoteModel>.from(_notes);

    // Filter by selected labels
    if (_selectedLabelIds.isNotEmpty) {
      result = result.where((n) {
        return _selectedLabelIds.any((labelId) => n.labelIds.contains(labelId));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((n) {
        return n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q);
      }).toList();
    }

    // Sort: pinned first, then by updatedAt descending
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return result;
  }

  List<NoteModel> get pinnedNotes =>
      filteredNotes.where((n) => n.isPinned).toList();

  List<NoteModel> get unpinnedNotes =>
      filteredNotes.where((n) => !n.isPinned).toList();

  // Reminders filtering
  List<ReminderModel> get filteredReminders {
    var result = List<ReminderModel>.from(_reminders);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      result = result.where((r) {
        return r.title.toLowerCase().contains(q) ||
            (r.description != null && r.description!.toLowerCase().contains(q));
      }).toList();
    }

    return result;
  }

  List<ReminderModel> get overdueReminders {
    final list = filteredReminders
        .where((r) => !r.isCompleted && r.dateTime.isBefore(DateTime.now()))
        .toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<ReminderModel> get upcomingReminders {
    final list = filteredReminders
        .where((r) => !r.isCompleted && !r.dateTime.isBefore(DateTime.now()))
        .toList();
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  List<ReminderModel> get completedReminders {
    final list = filteredReminders.where((r) => r.isCompleted).toList();
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  // Note actions
  Future<void> addNote(NoteModel note) async {
    _notes.insert(0, note);
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> updateNote(NoteModel note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note.copyWith(updatedAt: DateTime.now());
      await _storage.saveNotes(_notes);
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    // If note has an associated reminder, cancel its notifications
    final note = _notes.firstWhere(
      (n) => n.id == id,
      orElse: () => _notes.first,
    );
    if (note.reminderId != null) {
      await _notificationService.cancelReminderNotifications(note.reminderId!);
      _reminders.removeWhere((r) => r.id == note.reminderId);
      await _storage.saveReminders(_reminders);
    }

    _notes.removeWhere((n) => n.id == id);
    await _storage.saveNotes(_notes);
    notifyListeners();
  }

  Future<void> togglePinNote(String id) async {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final current = _notes[index];
      _notes[index] = current.copyWith(
        isPinned: !current.isPinned,
        updatedAt: DateTime.now(),
      );
      await _storage.saveNotes(_notes);
      notifyListeners();
    }
  }

  // Reminder actions
  Future<void> addReminder(ReminderModel reminder) async {
    _reminders.add(reminder);
    await _storage.saveReminders(_reminders);

    // If linked to a note, update the note model with reminder metadata
    if (reminder.noteId != null) {
      final nIndex = _notes.indexWhere((n) => n.id == reminder.noteId);
      if (nIndex != -1) {
        _notes[nIndex] = _notes[nIndex].copyWith(
          reminderId: reminder.id,
          reminderDateTime: reminder.dateTime,
        );
        await _storage.saveNotes(_notes);
      }
    }

    await _notificationService.scheduleReminderNotifications(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _storage.saveReminders(_reminders);

      if (reminder.noteId != null) {
        final nIndex = _notes.indexWhere((n) => n.id == reminder.noteId);
        if (nIndex != -1) {
          _notes[nIndex] = _notes[nIndex].copyWith(
            reminderId: reminder.id,
            reminderDateTime: reminder.dateTime,
          );
          await _storage.saveNotes(_notes);
        }
      }

      await _notificationService.scheduleReminderNotifications(reminder);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(int id) async {
    final rem = _reminders.where((r) => r.id == id).firstOrNull;
    if (rem != null && rem.noteId != null) {
      final nIndex = _notes.indexWhere((n) => n.id == rem.noteId);
      if (nIndex != -1) {
        _notes[nIndex] = _notes[nIndex].copyWith(
          reminderId: null,
          reminderDateTime: null,
        );
        await _storage.saveNotes(_notes);
      }
    }

    _reminders.removeWhere((r) => r.id == id);
    await _storage.saveReminders(_reminders);
    await _notificationService.cancelReminderNotifications(id);
    notifyListeners();
  }

  Future<void> toggleCompleteReminder(int id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final current = _reminders[index];
      final updated = current.copyWith(isCompleted: !current.isCompleted);
      _reminders[index] = updated;
      await _storage.saveReminders(_reminders);

      if (updated.isCompleted) {
        await _notificationService.cancelReminderNotifications(id);
      } else {
        await _notificationService.scheduleReminderNotifications(updated);
      }

      notifyListeners();
    }
  }
}
