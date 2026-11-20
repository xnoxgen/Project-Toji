import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/exercise_definition.dart';
import '../../data/models/workout_plan.dart';
import '../../state/physique_state.dart';
import 'exercise_library_sheet.dart';
import 'exercise_edit_dialog.dart';

class PlannerScreen extends StatefulWidget {
  final PhysiqueState state;
  final int? initialDayOfWeek;

  const PlannerScreen({super.key, required this.state, this.initialDayOfWeek});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late int _selectedDayOfWeek;

  @override
  void initState() {
    super.initState();
    _selectedDayOfWeek = widget.initialDayOfWeek ?? DateTime.now().weekday;
  }

  void _openExerciseLibrary() async {
    final result = await showModalBottomSheet<ExerciseDefinition>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExerciseLibrarySheet(state: widget.state),
    );

    if (result != null) {
      final planned = PlannedExercise(
        id: 'plan_${_selectedDayOfWeek}_${DateTime.now().millisecondsSinceEpoch}',
        exerciseId: result.id,
        name: result.name,
        muscleGroup: result.muscleGroup,
        targetSets: result.defaultSets,
        targetReps: result.defaultReps,
        restSeconds: result.defaultRestSeconds,
        notes: result.instructions,
      );
      await widget.state.addExerciseToDay(_selectedDayOfWeek, planned);
    }
  }

  void _editExercise(PlannedExercise exercise) async {
    final result = await showDialog<PlannedExercise>(
      context: context,
      builder: (ctx) => ExerciseEditDialog(exercise: exercise),
    );
    if (result != null) {
      await widget.state.updatePlannedExercise(_selectedDayOfWeek, result);
    }
  }

  void _editDayFocusDialog(DayWorkoutPlan plan) {
    final focusCtrl = TextEditingController(text: plan.focusName);
    bool isRest = plan.isRestDay;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text('Edit ${plan.dayName} Focus'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: focusCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Focus / Session Title',
                      hintText: 'e.g. Upper A, Push, Heavy Legs',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Mark as Rest Day'),
                    subtitle: const Text(
                      'Designates this day for physical recovery',
                    ),
                    value: isRest,
                    activeThumbColor: AppColors.crimson,
                    onChanged: (val) {
                      setDialogState(() => isRest = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await widget.state.updateDayFocus(
                      _selectedDayOfWeek,
                      focusCtrl.text.trim(),
                      isRest,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
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

    final plan = widget.state.getDayPlan(_selectedDayOfWeek);

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
        title: const Text('Weekly Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Day Title & Rest Mode',
            onPressed: () => _editDayFocusDialog(plan),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openExerciseLibrary,
        backgroundColor: AppColors.crimson,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Exercise',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              // Day Tabs
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: surfaceColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((d) {
                    final dayNum = d['day'] as int;
                    final isSelected = dayNum == _selectedDayOfWeek;
                    final dayData = widget.state.getDayPlan(dayNum);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () =>
                              setState(() => _selectedDayOfWeek = dayNum),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.crimson
                                  : (dayData.isRestDay
                                        ? Colors.transparent
                                        : (isDark
                                              ? elevatedColor
                                              : elevatedColor)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.crimson
                                    : borderColor,
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
                                        : textColor,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  dayData.isRestDay
                                      ? 'REST'
                                      : '${dayData.exercises.length}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : textMuted,
                                    fontSize: 9,
                                  ),
                                ),
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

              // Day Header Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                plan.dayName.toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.crimson,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (plan.isRestDay) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: elevatedColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Text(
                                    'REST DAY',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: textMuted,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan.focusName.isNotEmpty
                                ? plan.focusName
                                : 'Routine',
                            style: AppTypography.titleLarge.copyWith(
                              color: textColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.crimson,
                        size: 26,
                      ),
                      tooltip: 'Add Exercise',
                      onPressed: _openExerciseLibrary,
                    ),
                  ],
                ),
              ),

              // Exercises List (Reorderable)
              Expanded(
                child: plan.exercises.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                plan.isRestDay
                                    ? Icons.spa_rounded
                                    : Icons.fitness_center_rounded,
                                size: 48,
                                color: textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                plan.isRestDay
                                    ? 'Scheduled Rest Day'
                                    : 'No Exercises Added Yet',
                                style: AppTypography.titleLarge.copyWith(
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                plan.isRestDay
                                    ? 'Take this day to recover or tap "Add Exercise" to assign movements.'
                                    : 'Build your custom routine by adding exercises from the library.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _openExerciseLibrary,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.crimson,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Exercise'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: plan.exercises.length,
                        // ignore: deprecated_member_use
                        onReorder: (oldIndex, newIndex) {
                          widget.state.reorderExercises(
                            _selectedDayOfWeek,
                            oldIndex,
                            newIndex,
                          );
                        },
                        itemBuilder: (ctx, index) {
                          final ex = plan.exercises[index];
                          return Container(
                            key: ValueKey(ex.id),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              leading: Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: elevatedColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: AppColors.crimson,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ex.name,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
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
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '${ex.targetSets} sets × ${ex.targetReps} reps • ${ex.restSeconds}s rest',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (ex.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      ex.notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: textMuted.withValues(alpha: 0.8),
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: 20,
                                      color: textMuted,
                                    ),
                                    onSelected: (val) async {
                                      if (val == 'edit') {
                                        _editExercise(ex);
                                      } else if (val == 'duplicate') {
                                        await widget.state.duplicateExercise(
                                          _selectedDayOfWeek,
                                          ex.id,
                                        );
                                      } else if (val == 'delete') {
                                        await widget.state
                                            .removeExerciseFromDay(
                                              _selectedDayOfWeek,
                                              ex.id,
                                            );
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit_outlined, size: 18),
                                            SizedBox(width: 8),
                                            Text('Edit Targets'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'duplicate',
                                        child: Row(
                                          children: [
                                            Icon(Icons.copy_rounded, size: 18),
                                            SizedBox(width: 8),
                                            Text('Duplicate Exercise'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Remove Exercise',
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: textMuted,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
}
