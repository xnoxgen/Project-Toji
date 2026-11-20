import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/workout_session.dart';
import '../../state/physique_state.dart';

class ConsistencyScreen extends StatefulWidget {
  final PhysiqueState state;

  const ConsistencyScreen({super.key, required this.state});

  @override
  State<ConsistencyScreen> createState() => _ConsistencyScreenState();
}

class _ConsistencyScreenState extends State<ConsistencyScreen> {
  DateTime _currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  DateTime? _selectedCalendarDate;

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  String _dateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final elevatedColor = isDark
        ? AppColors.darkSurfaceElevated
        : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final completedKeys = widget.state.completedDateKeys;

    return Scaffold(
      appBar: AppBar(title: const Text('Streak & Consistency')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBadge(
                        'CURRENT STREAK',
                        '${widget.state.currentStreak}',
                        'days',
                        Icons.local_fire_department_rounded,
                        AppColors.crimson,
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricBadge(
                        'LONGEST STREAK',
                        '${widget.state.longestStreak}',
                        'days',
                        Icons.military_tech_rounded,
                        AppColors.warning,
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBadge(
                        'TOTAL SESSIONS',
                        '${widget.state.totalWorkoutsCompleted}',
                        'completed',
                        Icons.done_all_rounded,
                        AppColors.success,
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricBadge(
                        'WEEKLY RATE',
                        '${widget.state.weeklyConsistencyPercentage.toStringAsFixed(0)}%',
                        'discipline',
                        Icons.speed_rounded,
                        AppColors.crimson,
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Calendar Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      // Month Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            color: textColor,
                            onPressed: _prevMonth,
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(_currentMonth),
                            style: AppTypography.titleLarge.copyWith(
                              color: textColor,
                              fontSize: 17,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            color: textColor,
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Weekday Abbreviations
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((
                          day,
                        ) {
                          return SizedBox(
                            width: 36,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: AppTypography.labelSmall.copyWith(
                                color: textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Month Grid Days
                      _buildMonthCalendarGrid(
                        _currentMonth,
                        completedKeys,
                        isDark,
                        surfaceColor,
                        elevatedColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Selected Day Details if any
                if (_selectedCalendarDate != null) ...[
                  _buildSelectedDateInfo(
                    _selectedCalendarDate!,
                    completedKeys,
                    isDark,
                    surfaceColor,
                    borderColor,
                    textColor,
                    textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBadge(
    String label,
    String value,
    String unit,
    IconData icon,
    Color iconColor,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: textMuted,
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metricLarge.copyWith(
                  color: textColor,
                  fontSize: 26,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: AppTypography.labelSmall.copyWith(color: textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarGrid(
    DateTime month,
    Set<String> completedKeys,
    bool isDark,
    Color surfaceColor,
    Color elevatedColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 1 = Mon, 7 = Sun
    final startingWeekday = firstDayOfMonth.weekday;

    final cells = <Widget>[];

    // Leading blanks
    for (int i = 1; i < startingWeekday; i++) {
      cells.add(const SizedBox(width: 36, height: 36));
    }

    final today = DateTime.now();

    for (int d = 1; d <= daysInMonth; d++) {
      final cellDate = DateTime(month.year, month.month, d);
      final key = _dateKey(cellDate);
      final isCompleted = completedKeys.contains(key);
      final isToday =
          cellDate.year == today.year &&
          cellDate.month == today.month &&
          cellDate.day == today.day;
      final isSelected =
          _selectedCalendarDate != null &&
          _selectedCalendarDate!.year == cellDate.year &&
          _selectedCalendarDate!.month == cellDate.month &&
          _selectedCalendarDate!.day == cellDate.day;

      cells.add(
        InkWell(
          onTap: () {
            setState(() {
              _selectedCalendarDate = cellDate;
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.crimson
                  : (isSelected
                        ? (isDark ? elevatedColor : elevatedColor)
                        : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday
                    ? (isCompleted ? Colors.white : AppColors.crimson)
                    : (isSelected ? borderColor : Colors.transparent),
                width: isToday ? 1.5 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$d',
                  style: TextStyle(
                    color: isCompleted
                        ? Colors.white
                        : (isToday ? AppColors.crimson : textColor),
                    fontSize: 12,
                    fontWeight: isCompleted || isToday
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                if (isCompleted) ...[
                  const Icon(Icons.check, size: 8, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      children: cells,
    );
  }

  Widget _buildSelectedDateInfo(
    DateTime date,
    Set<String> completedKeys,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    final key = _dateKey(date);
    final isCompleted = completedKeys.contains(key);
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(date);

    // Look up session
    WorkoutSession? session;
    for (final s in widget.state.sessions) {
      if (_dateKey(s.date) == key) {
        session = s;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: AppTypography.titleMedium.copyWith(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.crimson.withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.lightSurfaceElevated),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isCompleted ? 'COMPLETED' : 'NO SESSION LOGGED',
                  style: AppTypography.labelSmall.copyWith(
                    color: isCompleted ? AppColors.crimson : textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (session != null) ...[
            const SizedBox(height: 10),
            Text(
              '${session.workoutName} • ${session.completedExercisesCount}/${session.totalExercisesCount} exercises',
              style: AppTypography.bodyMedium.copyWith(color: textMuted),
            ),
            if (session.exercises.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: session.exercises.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceElevated
                          : AppColors.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: e.isCompleted ? AppColors.crimson : borderColor,
                      ),
                    ),
                    child: Text(
                      '${e.name} ${e.isCompleted ? "✓" : ""}',
                      style: TextStyle(
                        fontSize: 11,
                        color: e.isCompleted ? AppColors.crimson : textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
