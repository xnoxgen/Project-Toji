import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'core/theme/app_theme.dart';
import 'data/services/label_storage_service.dart';
import 'data/services/notes_storage_service.dart';
import 'data/services/reminder_notification_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/widget_update_service.dart';
import 'state/notes_state.dart';
import 'state/physique_state.dart';
import 'ui/navigation/app_navigation_shell.dart';
import 'ui/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final storage = await StorageService.init();
  final notesStorage = await NotesStorageService.init();
  final labelStorage = await LabelStorageService.init();

  final physiqueState = PhysiqueState(storage);
  final notesState = NotesState(notesStorage, labelStorage);

  // Run the app immediately so the UI mounts and renders without blocking
  runApp(PhysiqueApp(state: physiqueState, notesState: notesState));

  // Initialize notifications and widget sync in background after the first frame renders
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      final notificationService = ReminderNotificationService();
      await notificationService.init();
    } catch (e) {
      debugPrint('NotificationService init error: $e');
    }

    try {
      await WidgetUpdateService.syncWidgetData(
        physiqueState: physiqueState,
        notesState: notesState,
      );
    } catch (e) {
      debugPrint('WidgetUpdateService initial sync error: $e');
    }

    // Keep native home widgets updated in real-time when Gym or Notes state changes
    physiqueState.addListener(() {
      WidgetUpdateService.syncWidgetData(
        physiqueState: physiqueState,
        notesState: notesState,
      );
    });
    notesState.addListener(() {
      WidgetUpdateService.syncWidgetData(
        physiqueState: physiqueState,
        notesState: notesState,
      );
    });
  });
}

class PhysiqueApp extends StatelessWidget {
  final PhysiqueState state;
  final NotesState notesState;

  const PhysiqueApp({super.key, required this.state, required this.notesState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'PHYSIQUE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            ...FlutterQuillLocalizations.supportedLocales,
          ],
          home: state.settings.hasCompletedOnboarding
              ? AppNavigationShell(notesState: notesState, physiqueState: state)
              : OnboardingScreen(
                  state: state,
                  onFinish: () {
                    // Rebuilds automatically through state change notification
                  },
                ),
        );
      },
    );
  }
}
