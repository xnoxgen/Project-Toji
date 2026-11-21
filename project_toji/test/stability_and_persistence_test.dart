import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_toji/data/models/app_settings.dart';
import 'package:project_toji/data/models/body_measurement.dart';
import 'package:project_toji/data/models/note_model.dart';
import 'package:project_toji/data/models/reminder_model.dart';
import 'package:project_toji/data/models/user_profile.dart';
import 'package:project_toji/data/models/workout_session.dart';
import 'package:project_toji/data/services/label_storage_service.dart';
import 'package:project_toji/data/services/notes_storage_service.dart';
import 'package:project_toji/data/services/storage_service.dart';
import 'package:project_toji/main.dart';
import 'package:project_toji/state/notes_state.dart';
import 'package:project_toji/state/physique_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Storage & Persistence Stabilization Tests', () {
    test('Empty notes persistence does not resurrect default notes', () async {
      SharedPreferences.setMockInitialValues({});
      final notesStorage = await NotesStorageService.init();

      // Initial load with no key returns default starter notes
      final initialNotes = notesStorage.loadNotes();
      expect(initialNotes, isNotEmpty);

      // User explicitly saves an empty list (all notes deleted)
      await notesStorage.saveNotes([]);

      // Reloading must return an empty list, NOT default notes
      final reloadedNotes = notesStorage.loadNotes();
      expect(reloadedNotes, isEmpty);
    });

    test(
      'Empty reminders persistence does not resurrect default reminders',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notesStorage = await NotesStorageService.init();

        // Initial load returns default reminders
        final initialReminders = notesStorage.loadReminders();
        expect(initialReminders, isNotEmpty);

        // User explicitly saves an empty list
        await notesStorage.saveReminders([]);

        // Reloading must return an empty list, NOT default reminders
        final reloadedReminders = notesStorage.loadReminders();
        expect(reloadedReminders, isEmpty);
      },
    );

    test('Note creation and deletion operates correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final notesStorage = await NotesStorageService.init();
      final labelStorage = await LabelStorageService.init();
      final notesState = NotesState(notesStorage, labelStorage);

      final newNote = NoteModel(
        id: 'custom_note_101',
        title: 'New PR on Squats',
        content: 'Hit 150kg for 3 reps cleanly.',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await notesState.addNote(newNote);
      expect(notesState.notes.any((n) => n.id == 'custom_note_101'), isTrue);

      await notesState.deleteNote('custom_note_101');
      expect(notesState.notes.any((n) => n.id == 'custom_note_101'), isFalse);
    });

    test(
      'Safe deletion of nonexistent note does not throw StateError',
      () async {
        SharedPreferences.setMockInitialValues({});
        final notesStorage = await NotesStorageService.init();
        final labelStorage = await LabelStorageService.init();
        final notesState = NotesState(notesStorage, labelStorage);

        // Delete non-existent note from non-empty state
        await expectLater(
          notesState.deleteNote('completely_fake_id'),
          completes,
        );

        // Delete all notes to make list empty
        await notesStorage.saveNotes([]);
        final emptyNotesState = NotesState(notesStorage, labelStorage);
        expect(emptyNotesState.notes, isEmpty);

        // Delete non-existent note from empty state must NOT throw StateError
        await expectLater(
          emptyNotesState.deleteNote('another_fake_id'),
          completes,
        );
      },
    );

    test('Reminder creation, completion toggle, and deletion', () async {
      SharedPreferences.setMockInitialValues({});
      final notesStorage = await NotesStorageService.init();
      final labelStorage = await LabelStorageService.init();
      final notesState = NotesState(notesStorage, labelStorage);

      final reminder = ReminderModel(
        id: 9999,
        title: 'Stretch Hamstrings',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        isCompleted: false,
        isNotificationEnabled: true,
        createdAt: DateTime.now(),
      );

      await notesState.addReminder(reminder);
      expect(notesState.reminders.any((r) => r.id == 9999), isTrue);
      expect(
        notesState.reminders.firstWhere((r) => r.id == 9999).isCompleted,
        isFalse,
      );

      // Toggle completed
      await notesState.toggleCompleteReminder(9999);
      expect(
        notesState.reminders.firstWhere((r) => r.id == 9999).isCompleted,
        isTrue,
      );

      // Delete reminder
      await notesState.deleteReminder(9999);
      expect(notesState.reminders.any((r) => r.id == 9999), isFalse);
    });

    test('Workout data persistence and session history roundtrip', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final physiqueState = PhysiqueState(storage);

      final session = WorkoutSession(
        id: 'session_persistence_test',
        date: DateTime.now(),
        dayOfWeek: 1,
        workoutName: 'Upper Body A',
        exercises: const [
          SessionExerciseLog(
            exerciseId: 'chest_press',
            name: 'Incline Dumbbell Press',
            muscleGroup: 'Chest',
            targetSets: 3,
            isCompleted: true,
            sets: [
              SetLog(
                setNumber: 1,
                actualReps: 10,
                weightKg: 34.0,
                isCompleted: true,
              ),
            ],
          ),
        ],
        isCompleted: true,
      );

      await physiqueState.saveSession(session);
      expect(
        physiqueState.sessions.any((s) => s.id == 'session_persistence_test'),
        isTrue,
      );

      // Reinitialize state from storage to test persistent disk loading
      final reloadedState = PhysiqueState(storage);
      expect(
        reloadedState.sessions.any((s) => s.id == 'session_persistence_test'),
        isTrue,
      );
      final loadedSession = reloadedState.sessions.firstWhere(
        (s) => s.id == 'session_persistence_test',
      );
      expect(loadedSession.workoutName, 'Upper Body A');
      expect(loadedSession.isCompleted, isTrue);
      expect(loadedSession.exercises.first.sets.first.weightKg, 34.0);
    });

    test('Comprehensive data models JSON serialization', () {
      // User Profile
      const profile = UserProfile(
        name: 'Alex',
        age: 22,
        sex: 'Male',
        heightCm: 180.0,
        currentWeightKg: 75.0,
        waistCm: 80.0,
        chestCm: 100.0,
        fitnessGoal: 'hypertrophy',
      );
      final profileJson = profile.toJson();
      expect(UserProfile.fromJson(profileJson).name, 'Alex');

      // App Settings
      const settings = AppSettings(
        themeMode: 'dark',
        defaultRestSeconds: 90,
        enableSound: false,
        enableVibration: true,
        hasCompletedOnboarding: true,
      );
      final settingsJson = settings.toJson();
      expect(AppSettings.fromJson(settingsJson).defaultRestSeconds, 90);

      // Body Measurement
      final measurement = BodyMeasurement(
        id: 'bm_1',
        date: DateTime.now(),
        metricType: 'weight',
        value: 76.5,
        unit: 'kg',
      );
      final measurementJson = measurement.toJson();
      expect(BodyMeasurement.fromJson(measurementJson).value, 76.5);
    });
  });

  group('Startup Bootstrap Widget Tests', () {
    testWidgets(
      'AppBootstrap renders loading indicator then mounts PhysiqueApp',
      (WidgetTester tester) async {
        final oldOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          if (details.toString().contains('ListTile background color')) {
            return;
          }
          oldOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = oldOnError);

        SharedPreferences.setMockInitialValues({
          'physique_app_settings':
              '{"hasCompletedOnboarding": true, "themeMode": "dark"}',
        });

        await tester.pumpWidget(const AppBootstrap());

        // While initializing, CircularProgressIndicator is rendered
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Settle async future
        await tester.pumpAndSettle();

        // Verifies bootstrap transitions cleanly to PhysiqueApp and AppNavigationShell
        expect(find.byType(PhysiqueApp), findsOneWidget);
        expect(find.text('Gym'), findsWidgets);
        expect(find.text('Notes'), findsWidgets);
      },
    );
  });
}
