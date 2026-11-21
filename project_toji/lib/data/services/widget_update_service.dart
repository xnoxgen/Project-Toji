import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../../data/models/workout_session.dart';
import '../../state/notes_state.dart';
import '../../state/physique_state.dart';

class WidgetUpdateService {
  static bool get _isTestEnv {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  static bool _isSyncing = false;
  static bool _hasPendingSync = false;

  /// Synchronizes current workout, streak, and reminder data with native Android home widgets.
  /// This method is strictly read-only and does NOT mutate state or trigger infinite notifyListeners loops.
  static Future<void> syncWidgetData({
    required PhysiqueState physiqueState,
    required NotesState notesState,
  }) async {
    if (_isTestEnv) return;

    if (_isSyncing) {
      _hasPendingSync = true;
      return;
    }
    _isSyncing = true;

    try {
      final now = DateTime.now();
      final todayPlan = physiqueState.getTodayPlan();

      // Look up today's session strictly in read-only mode (do NOT call getOrCreateTodaySession())
      final todayDateKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      WorkoutSession? todaySession;
      for (final s in physiqueState.sessions) {
        final sKey =
            '${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}';
        if (sKey == todayDateKey) {
          todaySession = s;
          break;
        }
      }

      final String workoutName;
      if (todayPlan.isRestDay) {
        workoutName = 'Rest Day';
      } else {
        workoutName = todayPlan.focusName.isNotEmpty
            ? todayPlan.focusName
            : 'Workout';
      }

      final String workoutFocus;
      if (!todayPlan.isRestDay && todayPlan.exercises.isNotEmpty) {
        final groups = todayPlan.exercises
            .map((e) => e.muscleGroup)
            .toSet()
            .toList();
        workoutFocus = groups.take(3).join(' • ');
      } else {
        workoutFocus = 'Rest & Recovery';
      }

      final isCompleted = todaySession?.isCompleted ?? false;
      final totalExercises =
          todaySession?.exercises.length ?? todayPlan.exercises.length;
      final completedExercises = todaySession?.completedExercisesCount ?? 0;
      final completionPct = todaySession?.completionPercentage.toInt() ?? 0;

      final String workoutStatus;
      if (isCompleted) {
        workoutStatus = 'Completed ($completedExercises/$totalExercises)';
      } else if (todayPlan.isRestDay) {
        workoutStatus = 'Recovery Day';
      } else if (totalExercises > 0) {
        workoutStatus =
            '$completedExercises/$totalExercises Done ($completionPct%)';
      } else {
        workoutStatus = 'No exercises assigned';
      }

      final streak = physiqueState.currentStreak;
      final todayDate = DateFormat('EEEE, MMM d').format(now);

      final monday = now.subtract(Duration(days: now.weekday - 1));
      int plannedWeek = 0;
      int completedWeek = 0;

      for (int i = 0; i < 7; i++) {
        final day = monday.add(Duration(days: i));
        final dayPlan = physiqueState.getDayPlan(day.weekday);
        if (!dayPlan.isRestDay && dayPlan.exercises.isNotEmpty) {
          plannedWeek++;
          final dateKey =
              '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
          if (physiqueState.completedDateKeys.contains(dateKey)) {
            completedWeek++;
          }
        }
      }

      final weeklyProgressText = '$completedWeek of $plannedWeek Done';
      final weeklyCompletionPct = plannedWeek > 0
          ? ((completedWeek / plannedWeek) * 100).clamp(0, 100).toInt()
          : 0;

      // Next upcoming reminder
      final upcomingReminders =
          notesState.reminders
              .where((r) => !r.isCompleted && r.dateTime.isAfter(now))
              .toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

      final nextReminder = upcomingReminders.firstOrNull;
      final String reminderTitle = nextReminder?.title.isNotEmpty == true
          ? nextReminder!.title
          : 'No upcoming alerts';
      final String reminderTime = nextReminder != null
          ? DateFormat('h:mm a').format(nextReminder.dateTime)
          : '';

      // Push all values into shared preferences storage for native widgets
      await HomeWidget.saveWidgetData<String>(
        'today_workout_name',
        workoutName,
      );
      await HomeWidget.saveWidgetData<String>(
        'today_workout_focus',
        workoutFocus,
      );
      await HomeWidget.saveWidgetData<String>(
        'today_workout_status',
        workoutStatus,
      );
      await HomeWidget.saveWidgetData<int>(
        'today_completion_pct',
        completionPct,
      );
      await HomeWidget.saveWidgetData<bool>('is_today_completed', isCompleted);
      await HomeWidget.saveWidgetData<int>('current_streak', streak);
      await HomeWidget.saveWidgetData<String>('today_date', todayDate);
      await HomeWidget.saveWidgetData<String>(
        'weekly_progress_text',
        weeklyProgressText,
      );
      await HomeWidget.saveWidgetData<int>(
        'weekly_completion_pct',
        weeklyCompletionPct,
      );
      await HomeWidget.saveWidgetData<String>(
        'next_reminder_title',
        reminderTitle,
      );
      await HomeWidget.saveWidgetData<String>(
        'next_reminder_time',
        reminderTime,
      );

      // Trigger native widget refresh safely
      await HomeWidget.updateWidget(
        name: 'TojiQuickGlanceWidget',
        androidName: 'TojiQuickGlanceWidget',
      );
      await HomeWidget.updateWidget(
        name: 'TojiDailyOverviewWidget',
        androidName: 'TojiDailyOverviewWidget',
      );
      await HomeWidget.updateWidget(
        name: 'TojiDashboardWidget',
        androidName: 'TojiDashboardWidget',
      );

      debugPrint('Home widgets synchronized successfully');
    } catch (e) {
      debugPrint('Error syncing home widget data: $e');
    } finally {
      _isSyncing = false;
      if (_hasPendingSync) {
        _hasPendingSync = false;
        // Schedule next sync on next tick to avoid stack overflow
        Future.microtask(
          () => syncWidgetData(
            physiqueState: physiqueState,
            notesState: notesState,
          ),
        );
      }
    }
  }
}
