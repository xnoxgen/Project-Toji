import 'package:flutter/foundation.dart';
import '../data/models/note_model.dart';
import '../data/models/reminder_model.dart';
import '../data/services/notes_storage_service.dart';
import '../data/services/notification_service.dart';

class NotesState extends ChangeNotifier {
  final NotesStorageService _storage;
  final NotificationService _notificationService = NotificationService();

  List<NoteModel> _notes = [];
  List<ReminderModel> _reminders = [];

  String _searchQuery = '';
  String? _selectedCategory; // null or 'All' = all categories
  int _activeModuleTab = 0; // 0 = Notes, 1 = Reminders

  NotesState(this._storage) {
    _loadData();
  }

  void _loadData() {
    _notes = _storage.loadNotes();
    _reminders = _storage.loadReminders();
    notifyListeners();
  }

  // Getters
  List<NoteModel> get notes => List.unmodifiable(_notes);
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
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

  void setSelectedCategory(String? category) {
    _selectedCategory = (category == null || category == 'All') ? null : category;
    notifyListeners();
  }

  // Notes filtering
  List<NoteModel> get filteredNotes {
    var result = List<NoteModel>.from(_notes);

    if (_selectedCategory != null && _selectedCategory != 'All') {
      result = result
          .where((n) => n.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

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
    await _notificationService.scheduleReminderNotification(reminder);
    notifyListeners();
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      await _storage.saveReminders(_reminders);
      await _notificationService.scheduleReminderNotification(reminder);
      notifyListeners();
    }
  }

  Future<void> deleteReminder(int id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _storage.saveReminders(_reminders);
    await _notificationService.cancelNotification(id);
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
        await _notificationService.cancelNotification(id);
      } else {
        await _notificationService.scheduleReminderNotification(updated);
      }

      notifyListeners();
    }
  }
}
