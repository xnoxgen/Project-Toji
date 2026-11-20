import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/physique_state.dart';
import '../dashboard/dashboard_screen.dart';
import '../planner/planner_screen.dart';
import '../progress/progress_screen.dart';
import '../consistency/consistency_screen.dart';
import '../settings/settings_screen.dart';

class MainScaffold extends StatefulWidget {
  final PhysiqueState state;

  const MainScaffold({super.key, required this.state});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  void navigateToTab(int index) => _navigateToTab(index);

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
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
      DashboardScreen(state: widget.state, onNavigateTab: _navigateToTab),
      PlannerScreen(state: widget.state),
      ProgressScreen(state: widget.state),
      ConsistencyScreen(state: widget.state),
      SettingsScreen(state: widget.state),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        if (isWideScreen) {
          // Desktop / Tablet layout with side NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: surfaceColor,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _navigateToTab,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'PHYSIQUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(
                        Icons.dashboard_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_today_outlined),
                      selectedIcon: Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Planner'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.trending_up_rounded),
                      selectedIcon: Icon(
                        Icons.show_chart_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Progress'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.local_fire_department_outlined),
                      selectedIcon: Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Streak'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(
                        Icons.settings_rounded,
                        color: AppColors.crimson,
                      ),
                      label: Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: pages),
                ),
              ],
            ),
          );
        }

        // Mobile layout with clean BottomNavigationBar
        return Scaffold(
          body: IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _navigateToTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: surfaceColor,
              selectedItemColor: AppColors.crimson,
              unselectedItemColor: textMuted,
              selectedLabelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              unselectedLabelStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined, size: 22),
                  activeIcon: Icon(Icons.dashboard_rounded, size: 22),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined, size: 22),
                  activeIcon: Icon(Icons.calendar_month_rounded, size: 22),
                  label: 'Planner',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.trending_up_rounded, size: 22),
                  activeIcon: Icon(Icons.show_chart_rounded, size: 22),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_fire_department_outlined, size: 22),
                  activeIcon: Icon(
                    Icons.local_fire_department_rounded,
                    size: 22,
                  ),
                  label: 'Streak',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined, size: 22),
                  activeIcon: Icon(Icons.settings_rounded, size: 22),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
