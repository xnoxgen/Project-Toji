import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/workout_session.dart';
import '../../state/physique_state.dart';
import 'exercise_execution_dialog.dart';
import 'workout_summary_dialog.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final PhysiqueState state;
  final int? initialDayOfWeek;

  const WorkoutExecutionScreen({
    super.key,
    required this.state,
    this.initialDayOfWeek,
  });

  @override
  State<WorkoutExecutionScreen> createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  late int _selectedDayOfWeek;

  @override
  void initState() {
    super.initState();
    _selectedDayOfWeek = widget.initialDayOfWeek ?? DateTime.now().weekday;
  }

  DateTime _getDateForDayOfWeek(int dayOfWeek) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    final diff = dayOfWeek - currentDay;
    return now.add(Duration(days: diff));
  }

  void _openExerciseModal(WorkoutSession session, SessionExerciseLog ex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ExerciseExecutionDialog(
        sessionId: session.id,
        exerciseLog: ex,
        state: widget.state,
      ),
    ).then((_) {
      // Check if all exercises are now completed
      final updatedSession = widget.state.getOrCreateSessionForDate(_getDateForDayOfWeek(_selectedDayOfWeek));
      if (updatedSession.isCompleted) {
        _showCompletionSummary(updatedSession);
      }
    });
  }

  void _showCompletionSummary(WorkoutSession session) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => WorkoutSummaryDialog(
        session: session,
        streak: widget.state.currentStreak,
        onDismiss: () => Navigator.of(ctx).pop(),
        onUndo: () {
          widget.state.undoWorkoutCompletion(session.id);
          Navigator.of(ctx).pop();
        },
      ),
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

    final targetDate = _getDateForDayOfWeek(_selectedDayOfWeek);
    final session = widget.state.getOrCreateSessionForDate(targetDate);
    final dayPlan = widget.state.getDayPlan(_selectedDayOfWeek);

    final days = [
      {'short': 'MON', 'day': 1},
      {'short': 'TUE', 'day': 2},
      {'short': 'WED', 'day': 3},
      {'short': 'THU', 'day': 4},
      {'short': 'FRI', 'day': 5},
      {'short': 'SAT', 'day': 6},
      {'short': 'SUN', 'day': 7},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Execution'),
        actions: [
          if (session.isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: () => _showCompletionSummary(session),
                icon: const Icon(Icons.military_tech_rounded, size: 18),
                label: const Text('Summary'),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Weekday Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: surfaceColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) {
                    final dayNum = d['day'] as int;
                    final isSelected = dayNum == _selectedDayOfWeek;
                    final isToday = dayNum == DateTime.now().weekday;
                    final isDayCompleted = widget.state.completedDateKeys.contains(
                      widget.state.getOrCreateSessionForDate(_getDateForDayOfWeek(dayNum)).date.toIso8601String().substring(0, 10),
                    );

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDayOfWeek = dayNum;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.crimson
                                  : (isToday
                                      ? (isDark ? elevatedColor : elevatedColor)
                                      : Colors.transparent),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.crimson
                                    : (isToday
                                        ? AppColors.crimson.withValues(alpha: 0.5)
                                        : borderColor),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  d['short'] as String,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (isToday ? textColor : textMuted),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (isDayCompleted) ...[
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 10,
                                    color: isSelected ? Colors.white : AppColors.crimson,
                                  ),
                                ] else ...[
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.white
                                          : (isToday ? AppColors.crimson : Colors.transparent),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),

              // Overview Progress Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dayPlan.focusName.isNotEmpty
                                    ? dayPlan.focusName
                                    : (dayPlan.isRestDay ? 'Rest & Recovery' : 'Workout Session'),
                                style: AppTypography.titleLarge.copyWith(
                                  color: textColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dayPlan.isRestDay
                                    ? 'Scheduled active recovery or rest'
                                    : '${session.completedExercisesCount} of ${session.totalExercisesCount} exercises finished',
                                style: AppTypography.bodyMedium.copyWith(color: textMuted),
                              ),
                            ],
                          ),
                        ),
                        if (session.isCompleted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.crimson),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_rounded, size: 14, color: AppColors.crimson),
                                const SizedBox(width: 4),
                                Text(
                                  'COMPLETED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.crimson,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            '${session.completionPercentage.toStringAsFixed(0)}%',
                            style: AppTypography.metricMedium.copyWith(
                              color: AppColors.crimson,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!dayPlan.isRestDay && session.totalExercisesCount > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: session.totalExercisesCount > 0
                              ? (session.completedExercisesCount / session.totalExercisesCount)
                              : 0.0,
                          backgroundColor: elevatedColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.crimson),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Exercises List or Rest Day State
              Expanded(
                child: dayPlan.isRestDay && session.exercises.isEmpty
                    ? _buildRestDayState(isDark, surfaceColor, borderColor, textColor, textMuted)
                    : session.exercises.isEmpty
                        ? _buildEmptyState(isDark, surfaceColor, borderColor, textColor, textMuted)
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: session.exercises.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                            itemBuilder: (ctx, index) {
                              final ex = session.exercises[index];
                              return _buildExerciseCard(
                                session,
                                ex,
                                index,
                                isDark,
                                surfaceColor,
                                elevatedColor,
                                borderColor,
                                textColor,
                                textMuted,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    WorkoutSession session,
    SessionExerciseLog ex,
    int index,
    bool isDark,
    Color surfaceColor,
    Color elevatedColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    final completedSetsCount = ex.sets.where((s) => s.isCompleted).length;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openExerciseModal(session, ex),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: ex.isCompleted
                ? AppColors.crimson.withValues(alpha: isDark ? 0.08 : 0.04)
                : surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ex.isCompleted ? AppColors.crimson : borderColor,
              width: ex.isCompleted ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Muscle group / status tick icon
              InkWell(
                onTap: () async {
                  if (ex.isCompleted) {
                    await widget.state.undoExerciseCompletion(session.id, ex.exerciseId);
                  } else {
                    await widget.state.markExerciseDone(session.id, ex.exerciseId);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ex.isCompleted
                        ? AppColors.crimson
                        : elevatedColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ex.isCompleted ? AppColors.crimson : borderColor,
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    ex.isCompleted ? Icons.check_rounded : Icons.fitness_center_rounded,
                    size: 18,
                    color: ex.isCompleted ? Colors.white : textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Target, Sets info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: elevatedColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ex.muscleGroup.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                        if (ex.isCompleted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.crimson, width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check, size: 9, color: AppColors.crimson),
                                const SizedBox(width: 3),
                                Text(
                                  'COMPLETED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.crimson,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (ex.notes.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.notes_rounded, size: 13, color: textMuted),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ex.name,
                      style: AppTypography.titleMedium.copyWith(
                        color: ex.isCompleted
                            ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                            : textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: ex.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ex.targetSets} sets × ${ex.targetReps} reps • ($completedSetsCount/${ex.targetSets} sets logged)',
                      style: AppTypography.bodyMedium.copyWith(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Explicit Complete / Completed Button
              InkWell(
                onTap: () async {
                  if (ex.isCompleted) {
                    await widget.state.undoExerciseCompletion(session.id, ex.exerciseId);
                  } else {
                    await widget.state.markExerciseDone(session.id, ex.exerciseId);
                    final updatedSession = widget.state.getOrCreateSessionForDate(
                      _getDateForDayOfWeek(_selectedDayOfWeek),
                    );
                    if (updatedSession.isCompleted) {
                      _showCompletionSummary(updatedSession);
                    }
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: ex.isCompleted
                        ? AppColors.crimson
                        : (isDark ? elevatedColor : elevatedColor),
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
                        size: 15,
                        color: ex.isCompleted ? Colors.white : AppColors.crimson,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        ex.isCompleted ? 'Completed' : 'Complete',
                        style: TextStyle(
                          color: ex.isCompleted ? Colors.white : textColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestDayState(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: const Icon(Icons.bed_rounded, size: 36, color: AppColors.crimson),
            ),
            const SizedBox(height: 18),
            Text(
              'Rest & Recovery',
              style: AppTypography.titleLarge.copyWith(color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Muscles grow while resting. Prioritize hydration, 8 hours of sleep, and gentle mobility work.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note_rounded, size: 48, color: textMuted),
            const SizedBox(height: 16),
            Text(
              'No Exercises Planned For Today',
              style: AppTypography.titleLarge.copyWith(color: textColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Open the Weekly Planner to assign exercises and build your custom routine.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

