import 'package:flutter_test/flutter_test.dart';
import 'package:project_toji/data/models/note_model.dart';
import 'package:project_toji/data/models/reminder_model.dart';
import 'package:project_toji/data/services/notes_storage_service.dart';
import 'package:project_toji/state/notes_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NoteModel Tests', () {
    test('JSON serialization, deserialization and copyWith', () {
      final now = DateTime.now();
      final note = NoteModel(
        id: 'note_123',
        title: 'Push Day Tips',
        content: 'Focus on incline dumbbell press and slow eccentrics.',
        category: 'Gym',
        isPinned: true,
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      expect(json['id'], 'note_123');
      expect(json['title'], 'Push Day Tips');
      expect(json['category'], 'Gym');
      expect(json['isPinned'], true);

      final deserialized = NoteModel.fromJson(json);
      expect(deserialized.id, 'note_123');
      expect(deserialized.title, 'Push Day Tips');
      expect(deserialized.category, 'Gym');
      expect(deserialized.isPinned, true);

      final updated = deserialized.copyWith(title: 'Updated Push Day');
      expect(updated.title, 'Updated Push Day');
      expect(updated.category, 'Gym');
    });
  });

  group('ReminderModel Tests', () {
    test('JSON serialization and overdue check', () {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2));
      final futureDate = DateTime.now().add(const Duration(hours: 5));

      final overdueReminder = ReminderModel(
        id: 101,
        title: 'Drink 1L Water',
        dateTime: pastDate,
        priority: 'high',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(overdueReminder.isOverdue, true);

      final completedOverdue = overdueReminder.copyWith(isCompleted: true);
      expect(completedOverdue.isOverdue, false);

      final futureReminder = ReminderModel(
        id: 102,
        title: 'Evening Creatine',
        dateTime: futureDate,
        priority: 'medium',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      expect(futureReminder.isOverdue, false);

      final json = futureReminder.toJson();
      final deserialized = ReminderModel.fromJson(json);
      expect(deserialized.id, 102);
      expect(deserialized.title, 'Evening Creatine');
      expect(deserialized.priority, 'medium');
    });
  });

  group('NotesState & Storage Tests', () {
    late NotesStorageService storage;
    late NotesState notesState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await NotesStorageService.init();
      notesState = NotesState(storage);
    });

    test('Loads default starter notes and reminders', () {
      expect(notesState.notes.isNotEmpty, true);
      expect(notesState.reminders.isNotEmpty, true);
    });

    test('Add, update, pin toggle and delete note', () async {
      final initialCount = notesState.notes.length;
      final newNote = NoteModel(
        id: 'test_new_1',
        title: 'Calculus Notes',
        content: 'Review integration by parts before Friday quiz.',
        category: 'College',
        isPinned: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notesState.addNote(newNote);
      expect(notesState.notes.length, initialCount + 1);
      expect(notesState.notes.first.id, 'test_new_1');

      // Toggle pin
      await notesState.togglePinNote('test_new_1');
      expect(notesState.notes.firstWhere((n) => n.id == 'test_new_1').isPinned, true);

      // Update
      await notesState.updateNote(
        newNote.copyWith(title: 'Advanced Calculus Notes'),
      );
      expect(
        notesState.notes.firstWhere((n) => n.id == 'test_new_1').title,
        'Advanced Calculus Notes',
      );

      // Delete
      await notesState.deleteNote('test_new_1');
      expect(notesState.notes.length, initialCount);
    });

    test('Notes filtering by search query and category', () async {
      notesState.setSelectedCategory('Gym');
      for (final note in notesState.filteredNotes) {
        expect(note.category.toLowerCase(), 'gym');
      }

      notesState.setSelectedCategory(null);
      notesState.setSearchQuery('Philosophy');
      expect(notesState.filteredNotes.any((n) => n.title.contains('Philosophy')), true);
    });

    test('Reminder completion and overdue splitting', () async {
      final now = DateTime.now();
      final overdueRem = ReminderModel(
        id: 991,
        title: 'Past Task',
        dateTime: now.subtract(const Duration(hours: 1)),
        isCompleted: false,
        createdAt: now,
      );
      final futureRem = ReminderModel(
        id: 992,
        title: 'Future Task',
        dateTime: now.add(const Duration(hours: 3)),
        isCompleted: false,
        createdAt: now,
      );

      await notesState.addReminder(overdueRem);
      await notesState.addReminder(futureRem);

      expect(notesState.overdueReminders.any((r) => r.id == 991), true);
      expect(notesState.upcomingReminders.any((r) => r.id == 992), true);

      // Complete overdue task
      await notesState.toggleCompleteReminder(991);
      expect(notesState.overdueReminders.any((r) => r.id == 991), false);
      expect(notesState.completedReminders.any((r) => r.id == 991), true);

      // Clean up
      await notesState.deleteReminder(991);
      await notesState.deleteReminder(992);
    });
  });
}
