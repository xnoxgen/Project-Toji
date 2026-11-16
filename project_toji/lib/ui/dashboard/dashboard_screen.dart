import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/metric_card.dart';
import '../../state/physique_state.dart';
import '../checkin/weekly_checkin_dialog.dart';
import '../execution/workout_execution_screen.dart';
import '../execution/workout_summary_dialog.dart';

class DashboardScreen extends StatelessWidget {
  final PhysiqueState state;
  final Function(int tabIndex) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onNavigateTab,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openCheckin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => WeeklyCheckinDialog(state: state),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevatedColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    final todaySession = state.getOrCreateTodaySession();
    final todayPlan = state.getTodayPlan();

    final latestWeight = state.getLatestMeasurement('weight') ?? state.profile.currentWeightKg;
    final weightDelta = state.getMeasurementDelta('weight');

    final latestWaist = state.getLatestMeasurement('waist') ?? state.profile.waistCm;
    final waistDelta = state.getMeasurementDelta('waist');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, ${state.profile.name}',
              style: AppTypography.titleLarge.copyWith(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              dateStr,
              style: AppTypography.labelSmall.copyWith(
                color: textMuted,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              state.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => state.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Settings',
            onPressed: () => onNavigateTab(4), // Tab index 4 = Settings
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Weekly Check-in Prompt Banner (if due)
                if (state.isWeeklyCheckInDue) ...[
                  _buildCheckinBanner(context, isDark, surfaceColor, borderColor, textColor, textMuted),
                  const SizedBox(height: 16),
                ],

                // Today's Workout Hero Card
                _buildTodayWorkoutHero(
                  context,
                  todayPlan,
                  todaySession,
                  isDark,
                  surfaceColor,
                  elevatedColor,
                  borderColor,
                  textColor,
                  textMuted,
                ),
                const SizedBox(height: 20),

                // Key Metrics Quick Row (Weight, Waist, Streak, Weekly Rate)
                Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Body Weight',
                        value: latestWeight.toStringAsFixed(1),
                        unit: 'kg',
                        delta: weightDelta,
                        targetText: state.profile.targetWeightKg != null
                            ? 'Goal: ${state.profile.targetWeightKg!.toStringAsFixed(1)}'
                            : null,
                        icon: Icons.monitor_weight_outlined,
                        onTap: () => onNavigateTab(2), // Progress tab
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Waist',
                        value: latestWaist != null ? latestWaist.toStringAsFixed(1) : '--',
                        unit: 'cm',
                        delta: waistDelta,
                        targetText: state.profile.targetWaistCm != null
                            ? 'Goal: ${state.profile.targetWaistCm!.toStringAsFixed(1)}'
                            : null,
                        icon: Icons.straighten_outlined,
                        onTap: () => onNavigateTab(2), // Progress tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Weekly Training Activity Card
                _buildWeeklyActivityCard(
                  context,
                  isDark,
                  surfaceColor,
                  elevatedColor,
                  borderColor,
                  textColor,
                  textMuted,
                ),
                const SizedBox(height: 20),

                // Quick Navigation Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        title: 'Workout Planner',
                        subtitle: 'Customize 7-day routine',
                        icon: Icons.calendar_month_outlined,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => onNavigateTab(1), // Planner tab
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionCard(
                        title: 'Progress Trends',
                        subtitle: 'Measurements & charts',
                        icon: Icons.show_chart_rounded,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textColor: textColor,
                        textMuted: textMuted,
                        onTap: () => onNavigateTab(2), // Progress tab
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckinBanner(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.crimson.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.crimson.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.crimson,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assessment_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Check-In Due',
                  style: AppTypography.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Record waist, weight & weekly consistency.',
                  style: AppTypography.bodyMedium.copyWith(color: textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _openCheckin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.crimson,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Check In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayWorkoutHero(
    BuildContext context,
    dynamic todayPlan,
    dynamic todaySession,
    bool isDark,
    Color surfaceColor,
    Color elevatedColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    final isRest = todayPlan.isRestDay && todayPlan.exercises.isEmpty;
    final completedCount = todaySession.completedExercisesCount;
    final totalCount = todaySession.totalExercisesCount;
    final isCompleted = todaySession.isCompleted;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppColors.crimson : borderColor,
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRest ? textMuted : AppColors.crimson,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TODAY'S SESSION",
                    style: AppTypography.labelSmall.copyWith(
                      color: isRest ? textMuted : AppColors.crimson,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (isCompleted) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.crimson.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 12, color: AppColors.crimson),
                      const SizedBox(width: 4),
                      Text(
                        'DONE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!isRest && totalCount > 0) ...[
                Text(
                  '$completedCount of $totalCount Done',
                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Workout Title
          Text(
            todayPlan.focusName.isNotEmpty
                ? todayPlan.focusName
                : (isRest ? 'Rest & Muscle Recovery' : 'Full Session'),
            style: AppTypography.displayMedium.copyWith(
              color: textColor,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRest
                ? 'Allow your central nervous system and muscles to rebuild.'
                : '${todayPlan.exercises.length} planned movements designed for hypertrophy & progressive overload.',
            style: AppTypography.bodyMedium.copyWith(color: textMuted),
          ),
          const SizedBox(height: 16),

          // Progress Bar (if not rest day)
          if (!isRest && totalCount > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: totalCount > 0 ? (completedCount / totalCount) : 0.0,
                backgroundColor: elevatedColor,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.crimson),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 16),

            // Exercise Checklist with Quick Complete Button
            ...todaySession.exercises.map((ex) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: ex.isCompleted
                      ? AppColors.crimson.withValues(alpha: isDark ? 0.08 : 0.04)
                      : (isDark ? elevatedColor : elevatedColor),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ex.isCompleted ? AppColors.crimson : borderColor,
                    width: ex.isCompleted ? 1.2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Exercise Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: surfaceColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ex.muscleGroup.toUpperCase(),
                                  style: AppTypography.labelSmall.copyWith(
                                    color: textMuted,
                                    fontSize: 8.5,
                                  ),
                                ),
                              ),
                              if (ex.isCompleted) ...[
                                const SizedBox(width: 5),
                                Text(
                                  'COMPLETED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.crimson,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ex.name,
                            style: AppTypography.titleMedium.copyWith(
                              color: ex.isCompleted ? textMuted : textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: ex.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text(
                            '${ex.targetSets} sets × ${ex.targetReps} reps',
                            style: TextStyle(color: textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Quick Complete / Completed Button
                    InkWell(
                      onTap: () async {
                        if (ex.isCompleted) {
                          await state.undoExerciseCompletion(todaySession.id, ex.exerciseId);
                        } else {
                          await state.markExerciseDone(todaySession.id, ex.exerciseId);
                          final updated = state.getOrCreateTodaySession();
                          if (updated.isCompleted && context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (ctx) => WorkoutSummaryDialog(
                                session: updated,
                                streak: state.currentStreak,
                                onDismiss: () => Navigator.of(ctx).pop(),
                                onUndo: () {
                                  state.undoWorkoutCompletion(updated.id);
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ex.isCompleted ? AppColors.crimson : surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ex.isCompleted ? AppColors.crimson : borderColor,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ex.isCompleted
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 14,
                              color: ex.isCompleted ? Colors.white : AppColors.crimson,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ex.isCompleted ? 'Completed' : 'Complete',
                              style: TextStyle(
                                color: ex.isCompleted ? Colors.white : textColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],

          // Action Button
          if (isRest) ...[
            OutlinedButton.icon(
              onPressed: () => onNavigateTab(1), // Go to planner to edit or view
              icon: const Icon(Icons.edit_calendar_outlined, size: 18),
              label: const Text('View Routine in Planner'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => WorkoutExecutionScreen(
                      state: state,
                      initialDayOfWeek: DateTime.now().weekday,
                    ),
                  ),
                );
              },
              icon: Icon(
                isCompleted ? Icons.visibility_rounded : Icons.play_arrow_rounded,
                size: 20,
              ),
              label: Text(
                isCompleted ? 'Review Workout Execution' : (completedCount > 0 ? 'Resume Workout' : 'Start Today\'s Workout'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimson,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyActivityCard(
    BuildContext context,
    bool isDark,
    Color surfaceColor,
    Color elevatedColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY TRAINING ACTIVITY',
                style: AppTypography.labelSmall.copyWith(
                  color: textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 14, color: AppColors.crimson),
                  const SizedBox(width: 4),
                  Text(
                    '${state.currentStreak} Day Streak',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.crimson,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7 Days Circles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayDate = monday.add(Duration(days: i));
              final dayNum = i + 1;
              final dayKey = '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';
              final isCompleted = state.completedDateKeys.contains(dayKey);
              final isToday = dayDate.day == now.day && dayDate.month == now.month && dayDate.year == now.year;
              final dayPlan = state.getDayPlan(dayNum);

              return Column(
                children: [
                  Text(
                    days[i],
                    style: AppTypography.labelSmall.copyWith(
                      color: isToday ? textColor : textMuted,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.crimson
                          : (dayPlan.isRestDay
                              ? Colors.transparent
                              : (isDark ? elevatedColor : elevatedColor)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? (isCompleted ? Colors.white : AppColors.crimson)
                            : (isCompleted ? AppColors.crimson : borderColor),
                        width: isToday ? 1.8 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: isCompleted
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : (dayPlan.isRestDay
                            ? Icon(Icons.bed_rounded, size: 14, color: textMuted)
                            : Text(
                                '${dayDate.day}',
                                style: TextStyle(
                                  color: isToday ? AppColors.crimson : textMuted,
                                  fontSize: 11,
                                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                ),
                              )),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color surfaceColor,
    required Color borderColor,
    required Color textColor,
    required Color textMuted,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.crimson, size: 22),
              const SizedBox(height: 10),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

