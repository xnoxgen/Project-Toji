import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notes_storage_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
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
  final notificationService = NotificationService();
  await notificationService.init();

  final physiqueState = PhysiqueState(storage);
  final notesState = NotesState(notesStorage);

  runApp(PhysiqueApp(
    state: physiqueState,
    notesState: notesState,
  ));
}

class PhysiqueApp extends StatelessWidget {
  final PhysiqueState state;
  final NotesState notesState;

  const PhysiqueApp({
    super.key,
    required this.state,
    required this.notesState,
  });

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
          home: state.settings.hasCompletedOnboarding
              ? AppNavigationShell(
                  notesState: notesState,
                  physiqueState: state,
                )
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
