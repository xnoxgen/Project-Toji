import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_toji/data/models/label_model.dart';
import 'package:project_toji/data/models/note_model.dart';
import 'package:project_toji/data/models/reminder_model.dart';
import 'package:project_toji/data/services/label_storage_service.dart';
import 'package:project_toji/data/services/notes_storage_service.dart';
import 'package:project_toji/data/services/reminder_notification_service.dart';
import 'package:project_toji/data/services/storage_service.dart';
import 'package:project_toji/data/services/widget_update_service.dart';
import 'package:project_toji/state/notes_state.dart';
import 'package:project_toji/state/physique_state.dart';
import 'package:project_toji/ui/notes/reminder_editor_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LabelModel Tests', () {
    test('JSON serialization, deserialization and copyWith', () {
      final label = LabelModel(
        id: 'label_test_1',
        name: 'Workouts',
        colorValue: 0xFFDC143C,
        createdAt: DateTime(2026, 11, 20),
      );

      final json = label.toJson();
      expect(json['id'], 'label_test_1');
      expect(json['name'], 'Workouts');
      expect(json['colorValue'], 0xFFDC143C);

      final deserialized = LabelModel.fromJson(json);
      expect(deserialized.id, 'label_test_1');
      expect(deserialized.name, 'Workouts');

      final updated = deserialized.copyWith(name: 'Heavy Lifting');
      expect(updated.name, 'Heavy Lifting');
      expect(updated.colorValue, 0xFFDC143C);
    });
  });

  group('NoteModel Rich Text & Label Tests', () {
    test('Rich text delta JSON serialization and labelIds preservation', () {
      final now = DateTime.now();
      final deltaOps = [
        {
          'insert': 'Heavy Squat Day\n',
          'attributes': {'bold': true},
        },
        {'insert': '5 sets of 5 reps at 140kg.\n'},
      ];
      final deltaJson = jsonEncode(deltaOps);

      final note = NoteModel(
        id: 'note_123',
        title: 'Push Day Tips',
        content: 'Heavy Squat Day\n5 sets of 5 reps at 140kg.',
        contentJson: deltaJson,
        labelIds: const ['label_important', 'label_gym'],
        category: 'Gym',
        isPinned: true,
        reminderId: 101,
        reminderDateTime: now.add(const Duration(hours: 2)),
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      expect(json['id'], 'note_123');
      expect(json['contentJson'], deltaJson);
      expect(json['labelIds'], ['label_important', 'label_gym']);
      expect(json['reminderId'], 101);

      final deserialized = NoteModel.fromJson(json);
      expect(deserialized.id, 'note_123');
      expect(deserialized.contentJson, deltaJson);
      expect(deserialized.labelIds, ['label_important', 'label_gym']);
      expect(deserialized.reminderId, 101);

      final updated = deserialized.copyWith(title: 'Updated Push Day');
      expect(updated.title, 'Updated Push Day');
      expect(updated.labelIds, ['label_important', 'label_gym']);
    });
  });

  group('ReminderModel Advance Notification Tests', () {
    test('Advance notification calculations and toggling', () {
      final targetTime = DateTime(2026, 11, 21, 18, 0); // 6:00 PM

      final reminder = ReminderModel(
        id: 201,
        title: 'Gym Session',
        description: 'Focus on chest and triceps',
        dateTime: targetTime,
        priority: 'high',
        isNotificationEnabled: true,
        advanceMinutes: 10,
        noteId: 'note_123',
        noteTitle: 'Push Day Tips',
        createdAt: DateTime.now(),
      );

      expect(reminder.advanceMinutes, 10);
      expect(reminder.isNotificationEnabled, true);
      // Advance time must be 5:50 PM (10 min before 6:00 PM)
      expect(reminder.advanceDateTime, DateTime(2026, 11, 21, 17, 50));

      final json = reminder.toJson();
      final deserialized = ReminderModel.fromJson(json);
      expect(deserialized.advanceMinutes, 10);
      expect(deserialized.isNotificationEnabled, true);
      expect(deserialized.noteId, 'note_123');
      expect(deserialized.noteTitle, 'Push Day Tips');
    });

    test('Single notification time calculations for all advance options', () {
      final scheduledTime = DateTime(2026, 11, 20, 23, 7); // 11:07 PM

      // 1. At time (0m) -> 11:07 PM
      final rAtTime = ReminderModel(
        id: 1,
        title: 'At time test',
        dateTime: scheduledTime,
        advanceMinutes: 0,
        createdAt: DateTime.now(),
      );
      expect(rAtTime.advanceDateTime, scheduledTime);

      // 2. 5m before -> 11:02 PM
      final r5m = rAtTime.copyWith(advanceMinutes: 5);
      expect(r5m.advanceDateTime, DateTime(2026, 11, 20, 23, 2));

      // 3. 10m before -> 10:57 PM
      final r10m = rAtTime.copyWith(advanceMinutes: 10);
      expect(r10m.advanceDateTime, DateTime(2026, 11, 20, 22, 57));

      // 4. 15m before -> 10:52 PM
      final r15m = rAtTime.copyWith(advanceMinutes: 15);
      expect(r15m.advanceDateTime, DateTime(2026, 11, 20, 22, 52));

      // 5. Custom 30m before -> 10:37 PM
      final rCustom = rAtTime.copyWith(advanceMinutes: 30);
      expect(rCustom.advanceDateTime, DateTime(2026, 11, 20, 22, 37));
    });
  });

  group('NotesState Label Management & Filtering Tests', () {
    late NotesStorageService storage;
    late LabelStorageService labelStorage;
    late NotesState notesState;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await NotesStorageService.init();
      labelStorage = await LabelStorageService.init();
      notesState = NotesState(storage, labelStorage);
    });

    test('Initializes default labels and starter notes', () {
      expect(notesState.labels.isNotEmpty, true);
      expect(notesState.labels.any((l) => l.name == 'Personal'), true);
      expect(notesState.labels.any((l) => l.name == 'Important'), true);
      expect(notesState.notes.isNotEmpty, true);
    });

    test('Add label and prevent duplicates', () async {
      final success = await notesState.addLabel('Cardio', 0xFF10B981);
      expect(success, true);
      expect(notesState.labels.any((l) => l.name == 'Cardio'), true);

      // Attempt duplicate
      final duplicate = await notesState.addLabel('cardio', 0xFFDC143C);
      expect(duplicate, false);
    });

    test(
      'Deleting a label removes it from notes without deleting the notes',
      () async {
        await notesState.addLabel('Deadlifts', 0xFFDC143C);
        final label = notesState.labels.firstWhere(
          (l) => l.name == 'Deadlifts',
        );

        final newNote = NoteModel(
          id: 'test_note_deadlifts',
          title: 'Deadlift PR Attempts',
          content: 'Work up to 220kg single.',
          labelIds: [label.id, 'label_important'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await notesState.addNote(newNote);

        expect(
          notesState.notes
              .firstWhere((n) => n.id == 'test_note_deadlifts')
              .labelIds
              .contains(label.id),
          true,
        );

        // Delete the label
        await notesState.deleteLabel(label.id);

        // Label is deleted
        expect(notesState.labels.any((l) => l.id == label.id), false);

        // Note still exists, but label association was cleanly removed
        final noteAfter = notesState.notes.firstWhere(
          (n) => n.id == 'test_note_deadlifts',
        );
        expect(noteAfter.labelIds.contains(label.id), false);
        expect(noteAfter.labelIds.contains('label_important'), true);
      },
    );

    test('Filter notes by label and search query combined', () async {
      // Find 'label_study'
      final studyLabel = notesState.labels.firstWhere(
        (l) => l.id == 'label_study',
      );

      notesState.selectSingleLabelFilter(studyLabel.id);
      for (final note in notesState.filteredNotes) {
        expect(note.labelIds.contains(studyLabel.id), true);
      }

      // Add search query while label filter is active
      notesState.setSearchQuery('Study');
      expect(notesState.filteredNotes.length, 1);

      // Clear filters
      notesState.clearLabelFilters();
      notesState.setSearchQuery('');
      expect(notesState.filteredNotes.length, notesState.notes.length);
    });
  });

  group('ReminderEditorDialog UI & Single-Selection Tests', () {
    testWidgets(
      'Edit Reminder screen displays exactly ONE notification toggle and advance section',
      (tester) async {
        final existingReminder = ReminderModel(
          id: 42,
          title: 'Post Workout Shake',
          dateTime: DateTime.now().add(const Duration(hours: 3)),
          isNotificationEnabled: true,
          advanceMinutes: 10,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReminderEditorDialog(
                initialReminder: existingReminder,
                onSave: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Exactly ONE notification toggle header
        expect(find.text('Enable Alert Notification'), findsOneWidget);
        expect(
          find.text('Triggers system notification on your device'),
          findsOneWidget,
        );
        expect(find.byType(Switch), findsOneWidget);

        // Exactly ONE advance notification section
        expect(find.text('Advance Notification'), findsOneWidget);
        expect(find.text('At time'), findsOneWidget);
        expect(find.text('5m before'), findsOneWidget);
        expect(find.text('10m before'), findsOneWidget);
        expect(find.text('15m before'), findsOneWidget);
        expect(find.text('Custom...'), findsOneWidget);

        // Exactly ONE Priority Level section
        expect(find.text('Priority Level'), findsOneWidget);
      },
    );

    testWidgets(
      'New Reminder screen displays exactly ONE notification toggle and advance section',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: ReminderEditorDialog(onSave: (_) {})),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Enable Alert Notification'), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        expect(find.text('Advance Notification'), findsOneWidget);
      },
    );

    testWidgets(
      'Advance notification options are mutually exclusive and save single selected interval',
      (tester) async {
        ReminderModel? savedReminder;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReminderEditorDialog(onSave: (r) => savedReminder = r),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter title
        await tester.enterText(
          find.widgetWithText(TextField, 'Reminder Title'),
          'Mobility Work',
        );
        await tester.pumpAndSettle();

        // Tap 5m before ChoiceChip
        await tester.tap(find.text('5m before'));
        await tester.pumpAndSettle();

        // Save
        await tester.tap(find.text('Set Reminder'));
        await tester.pumpAndSettle();

        expect(savedReminder, isNotNull);
        expect(savedReminder!.title, 'Mobility Work');
        expect(savedReminder!.advanceMinutes, 5);
        expect(savedReminder!.isNotificationEnabled, true);
      },
    );
  });

  group('ReminderNotificationService & WidgetUpdateService Tests', () {
    test(
      'ReminderNotificationService methods run cleanly in test environment',
      () async {
        final service = ReminderNotificationService();
        await service.init();

        final notifs = await service.areNotificationsEnabled();
        expect(notifs, isTrue);

        final exact = await service.canScheduleExactAlarms();
        expect(exact, isTrue);

        final testSuccess = await service.sendTestNotification(delaySeconds: 5);
        expect(testSuccess, isTrue);

        final pending = await service.getPendingNotifications();
        expect(pending, isEmpty);

        final reminder = ReminderModel(
          id: 777,
          title: 'Hydration',
          dateTime: DateTime.now().add(const Duration(minutes: 30)),
          isNotificationEnabled: true,
          createdAt: DateTime.now(),
        );
        final scheduled = await service.scheduleReminderNotifications(reminder);
        expect(scheduled, isTrue);

        await service.cancelReminderNotifications(777);
      },
    );

    test('WidgetUpdateService executes cleanly without throwing', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final notesStorage = await NotesStorageService.init();
      final labelStorage = await LabelStorageService.init();

      final physiqueState = PhysiqueState(storage);
      final notesState = NotesState(notesStorage, labelStorage);

      await expectLater(
        WidgetUpdateService.syncWidgetData(
          physiqueState: physiqueState,
          notesState: notesState,
        ),
        completes,
      );
    });
  });
}
