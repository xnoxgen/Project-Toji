import 'package:flutter/foundation.dart';
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

void main() {
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

  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_AppServices> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _initialize();
  }

  Future<_AppServices> _initialize() async {
    final storage = await StorageService.init();
    final notesStorage = await NotesStorageService.init();
    final labelStorage = await LabelStorageService.init();

    final physiqueState = PhysiqueState(storage);
    final notesState = NotesState(notesStorage, labelStorage);

    return _AppServices(physiqueState: physiqueState, notesState: notesState);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppServices>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: const Color(0xFF121212),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to initialize PHYSIQUE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        kReleaseMode
                            ? 'An unexpected error occurred during startup.'
                            : '${snapshot.error}',
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _initialization = _initialize();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC143C),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF121212),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFDC143C)),
              ),
            ),
          );
        }

        final services = snapshot.data!;

        return PhysiqueApp(
          state: services.physiqueState,
          notesState: services.notesState,
        );
      },
    );
  }
}

class _AppServices {
  final PhysiqueState physiqueState;
  final NotesState notesState;

  const _AppServices({required this.physiqueState, required this.notesState});
}

class PhysiqueApp extends StatefulWidget {
  final PhysiqueState state;
  final NotesState notesState;

  const PhysiqueApp({super.key, required this.state, required this.notesState});

  @override
  State<PhysiqueApp> createState() => _PhysiqueAppState();
}

class _PhysiqueAppState extends State<PhysiqueApp> {
  bool _postFrameServicesInitialized = false;
  VoidCallback? _physiqueListener;
  VoidCallback? _notesListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _postFrameServicesInitialized) return;
      _postFrameServicesInitialized = true;

      try {
        final notificationService = ReminderNotificationService();
        await notificationService.init();
      } catch (e) {
        debugPrint('NotificationService init error: $e');
      }

      try {
        await WidgetUpdateService.syncWidgetData(
          physiqueState: widget.state,
          notesState: widget.notesState,
        );
      } catch (e) {
        debugPrint('WidgetUpdateService initial sync error: $e');
      }

      _physiqueListener = () {
        WidgetUpdateService.syncWidgetData(
          physiqueState: widget.state,
          notesState: widget.notesState,
        );
      };
      _notesListener = () {
        WidgetUpdateService.syncWidgetData(
          physiqueState: widget.state,
          notesState: widget.notesState,
        );
      };

      widget.state.addListener(_physiqueListener!);
      widget.notesState.addListener(_notesListener!);
    });
  }

  @override
  void dispose() {
    if (_physiqueListener != null) {
      widget.state.removeListener(_physiqueListener!);
    }
    if (_notesListener != null) {
      widget.notesState.removeListener(_notesListener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        return MaterialApp(
          title: 'PHYSIQUE',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: widget.state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
          home: widget.state.settings.hasCompletedOnboarding
              ? AppNavigationShell(
                  notesState: widget.notesState,
                  physiqueState: widget.state,
                )
              : OnboardingScreen(
                  state: widget.state,
                  onFinish: () {
                    // Rebuilds automatically through state change notification
                  },
                ),
        );
      },
    );
  }
}
