import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'state/physique_state.dart';
import 'ui/navigation/main_scaffold.dart';
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
  final physiqueState = PhysiqueState(storage);

  runApp(PhysiqueApp(state: physiqueState));
}

class PhysiqueApp extends StatelessWidget {
  final PhysiqueState state;

  const PhysiqueApp({super.key, required this.state});

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
              ? MainScaffold(state: state)
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
