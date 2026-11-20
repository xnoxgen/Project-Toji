import 'dart:async';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/services/reminder_notification_service.dart';
import '../../state/notes_state.dart';
import '../../state/physique_state.dart';
import '../notes/notes_screen.dart';
import 'main_scaffold.dart';

class AppNavigationShell extends StatefulWidget {
  final NotesState notesState;
  final PhysiqueState physiqueState;

  const AppNavigationShell({
    super.key,
    required this.notesState,
    required this.physiqueState,
  });

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  // Default destination after onboarding: 1 (Gym), preserving existing app-opening experience
  int _currentTopIndex = 1;

  final GlobalKey<NotesScreenState> _notesKey = GlobalKey<NotesScreenState>();
  final GlobalKey<MainScaffoldState> _gymKey = GlobalKey<MainScaffoldState>();

  StreamSubscription<Uri?>? _widgetSub;
  StreamSubscription<String?>? _notificationSub;

  bool get _isTestEnv {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  @override
  void initState() {
    super.initState();

    if (!_isTestEnv) {
      // Check if application was launched from a home widget tap
      HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
        if (uri != null) _handleDeepLink(uri);
      });

      // Listen for interactive home widget taps while app is in foreground/background
      _widgetSub = HomeWidget.widgetClicked.listen((uri) {
        if (uri != null) _handleDeepLink(uri);
      });

      // Listen for reminder notification taps
      _notificationSub = ReminderNotificationService().onNotificationClicked
          .listen((payload) {
            if (payload != null) _handleNotificationPayload(payload);
          });
    }
  }

  @override
  void dispose() {
    _widgetSub?.cancel();
    _notificationSub?.cancel();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (_currentTopIndex != index) {
      setState(() {
        _currentTopIndex = index;
      });
    }
  }

  void _handleDeepLink(Uri uri) {
    final host = uri.host.toLowerCase();
    final scheme = uri.scheme.toLowerCase();
    if (scheme != 'toji') return;

    debugPrint('AppNavigationShell handling deep link: $uri (host: $host)');

    switch (host) {
      case 'workout':
        setState(() => _currentTopIndex = 1);
        _gymKey.currentState?.navigateToTab(0);
        break;
      case 'gym':
        setState(() => _currentTopIndex = 1);
        break;
      case 'streak':
        setState(() => _currentTopIndex = 1);
        _gymKey.currentState?.navigateToTab(3);
        break;
      case 'progress':
        setState(() => _currentTopIndex = 1);
        _gymKey.currentState?.navigateToTab(2);
        break;
      case 'notes':
        setState(() => _currentTopIndex = 0);
        break;
      case 'add_note':
        setState(() => _currentTopIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notesKey.currentState?.openNoteEditor();
        });
        break;
      case 'reminder':
        setState(() => _currentTopIndex = 0);
        widget.notesState.setActiveModuleTab(1);
        break;
      default:
        setState(() => _currentTopIndex = 1);
        break;
    }
  }

  void _handleNotificationPayload(String payload) {
    debugPrint('AppNavigationShell handling notification payload: $payload');
    if (payload == 'test_alert') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E)),
              SizedBox(width: 10),
              Text('Project Toji alert received successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (payload.startsWith('note:')) {
      final noteId = payload.substring('note:'.length);
      setState(() => _currentTopIndex = 0);
      widget.notesState.setActiveModuleTab(0);
      final note = widget.notesState.notes
          .where((n) => n.id == noteId)
          .firstOrNull;
      if (note != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _notesKey.currentState?.openNoteEditor(note);
        });
      }
    } else if (payload.startsWith('reminder:')) {
      setState(() => _currentTopIndex = 0);
      widget.notesState.setActiveModuleTab(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final pages = [
      NotesScreen(
        key: _notesKey,
        notesState: widget.notesState,
        physiqueState: widget.physiqueState,
      ),
      MainScaffold(key: _gymKey, state: widget.physiqueState),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        if (isWideScreen) {
          // Desktop / Tablet layout with slim primary top-level rail on far left
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: surfaceColor,
                  selectedIndex: _currentTopIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  minWidth: 72,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.crimson,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TOJI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.note_alt_outlined),
                      selectedIcon: Icon(
                        Icons.note_alt_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Notes'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fitness_center_outlined),
                      selectedIcon: Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Gym'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentTopIndex, children: pages),
                ),
              ],
            ),
          );
        }

        // Mobile layout: App-level bottom navigation bar with exactly TWO destinations (Notes and Gym)
        return Scaffold(
          body: IndexedStack(index: _currentTopIndex, children: pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    // Destination 1: Notes
                    Expanded(
                      child: _buildTopNavButton(
                        index: 0,
                        icon: Icons.note_alt_outlined,
                        activeIcon: Icons.note_alt_rounded,
                        label: 'Notes',
                        isSelected: _currentTopIndex == 0,
                        textMuted: textMuted,
                      ),
                    ),
                    Container(width: 1, height: 24, color: borderColor),
                    // Destination 2: Gym
                    Expanded(
                      child: _buildTopNavButton(
                        index: 1,
                        icon: Icons.fitness_center_outlined,
                        activeIcon: Icons.fitness_center_rounded,
                        label: 'Gym',
                        isSelected: _currentTopIndex == 1,
                        textMuted: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopNavButton({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color textMuted,
  }) {
    return InkWell(
      onTap: () => _onDestinationSelected(index),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.crimson.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.crimson.withAlpha(80)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 20,
                color: isSelected ? AppColors.crimson : textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? AppColors.crimson : textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
