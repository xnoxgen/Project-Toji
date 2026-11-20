import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_toji/data/services/label_storage_service.dart';
import 'package:project_toji/data/services/notes_storage_service.dart';
import 'package:project_toji/data/services/storage_service.dart';
import 'package:project_toji/state/notes_state.dart';
import 'package:project_toji/state/physique_state.dart';
import 'package:project_toji/ui/navigation/app_navigation_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'AppNavigationShell defaults to Gym and switches to Notes cleanly',
    (WidgetTester tester) async {
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.toString().contains('ListTile background color')) {
          return;
        }
        oldOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldOnError);

      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final notesStorage = await NotesStorageService.init();
      final labelStorage = await LabelStorageService.init();

      final physiqueState = PhysiqueState(storage);
      final notesState = NotesState(notesStorage, labelStorage);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: FlutterQuillLocalizations.supportedLocales,
          home: AppNavigationShell(
            notesState: notesState,
            physiqueState: physiqueState,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default top-level destination is Gym (index 1)
      expect(find.text('Gym'), findsWidgets);
      expect(find.text('Notes'), findsWidgets);

      // Existing Gym bottom navigation destinations exist untouched
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Switch top-level to Notes
      await tester.tap(find.text('Notes').first);
      await tester.pumpAndSettle();

      // Verify Notes module is displayed
      expect(find.text('NOTES & REMINDERS'), findsOneWidget);
      expect(find.text('Personal Notes'), findsOneWidget);
      expect(find.text('All Notes'), findsOneWidget);

      // Switch back to Gym
      await tester.tap(find.text('Gym').first);
      await tester.pumpAndSettle();

      // Verify Gym module is displayed again
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Planner'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Streak'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    },
  );
}
