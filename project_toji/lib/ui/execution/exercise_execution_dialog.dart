import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/workout_session.dart';
import '../../state/physique_state.dart';
import 'rest_timer_widget.dart';

class ExerciseExecutionDialog extends StatefulWidget {
  final String sessionId;
  final SessionExerciseLog exerciseLog;
  final PhysiqueState state;

  const ExerciseExecutionDialog({
    super.key,
    required this.sessionId,
    required this.exerciseLog,
    required this.state,
  });

  @override
  State<ExerciseExecutionDialog> createState() =>
      _ExerciseExecutionDialogState();
}

class _ExerciseExecutionDialogState extends State<ExerciseExecutionDialog> {
  late List<SetLog> _sets;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _sets = List<SetLog>.from(widget.exerciseLog.sets);
    if (_sets.isEmpty) {
      _sets = List.generate(
        widget.exerciseLog.targetSets,
        (i) => SetLog(
          setNumber: i + 1,
          targetReps: widget.exerciseLog.targetReps,
          actualReps: 10,
          weightKg: 0.0,
          isCompleted: false,
        ),
      );
    }
    _notesController = TextEditingController(text: widget.exerciseLog.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _updateSetWeight(int index, double delta) {
    setState(() {
      final cur = _sets[index].weightKg;
      final next = (cur + delta).clamp(0.0, 500.0);
      _sets[index] = _sets[index].copyWith(weightKg: next);
    });
  }

  void _updateSetReps(int index, int delta) {
    setState(() {
      final cur = _sets[index].actualReps;
      final next = (cur + delta).clamp(1, 100);
      _sets[index] = _sets[index].copyWith(actualReps: next);
    });
  }

  void _toggleSetCompleted(int index) {
    setState(() {
      final cur = _sets[index].isCompleted;
      _sets[index] = _sets[index].copyWith(isCompleted: !cur);
    });
  }

  void _addSet() {
    setState(() {
      final lastWeight = _sets.isNotEmpty ? _sets.last.weightKg : 0.0;
      final lastReps = _sets.isNotEmpty ? _sets.last.actualReps : 10;
      _sets.add(
        SetLog(
          setNumber: _sets.length + 1,
          targetReps: widget.exerciseLog.targetReps,
          actualReps: lastReps,
          weightKg: lastWeight,
          isCompleted: false,
        ),
      );
    });
  }

  void _removeSet(int index) {
    if (_sets.length <= 1) return;
    setState(() {
      _sets.removeAt(index);
      for (int i = 0; i < _sets.length; i++) {
        _sets[i] = _sets[i].copyWith(setNumber: i + 1);
      }
    });
  }

  Future<void> _handleDone() async {
    // Save sets to state
    for (int i = 0; i < _sets.length; i++) {
      await widget.state.updateSetLog(
        sessionId: widget.sessionId,
        exerciseId: widget.exerciseLog.exerciseId,
        setIndex: i,
        weight: _sets[i].weightKg,
        actualReps: _sets[i].actualReps,
        isCompleted: true,
      );
    }
    await widget.state.markExerciseDone(
      widget.sessionId,
      widget.exerciseLog.exerciseId,
    );
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Dialog(
      backgroundColor: surfaceColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.crimson.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.exerciseLog.muscleGroup.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.crimson,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.exerciseLog.name,
                          style: AppTypography.titleLarge.copyWith(
                            color: textColor,
                            fontSize: 19,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Target: ${widget.exerciseLog.targetSets} sets × ${widget.exerciseLog.targetReps} reps',
                          style: AppTypography.bodyMedium.copyWith(
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: textMuted,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructions & Notes if present
                    if (widget.exerciseLog.notes.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceElevated
                              : AppColors.lightSurfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.exerciseLog.notes,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Set headers
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            'SET',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'WEIGHT (KG)',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'REPS',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'DONE',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sets list
                    ...List.generate(_sets.length, (index) {
                      final set = _sets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: set.isCompleted
                              ? AppColors.crimson.withValues(
                                  alpha: isDark ? 0.1 : 0.05,
                                )
                              : (isDark
                                    ? AppColors.darkSurfaceElevated
                                    : AppColors.lightSurfaceElevated),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: set.isCompleted
                                ? AppColors.crimson
                                : borderColor,
                            width: set.isCompleted ? 1.2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Set Number
                            SizedBox(
                              width: 34,
                              child: Text(
                                '${set.setNumber}',
                                style: AppTypography.titleMedium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            // Weight Controls
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => _updateSetWeight(index, -2.5),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      set.weightKg.toStringAsFixed(1),
                                      textAlign: TextAlign.center,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _updateSetWeight(index, 2.5),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 14,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Reps Controls
                            Expanded(
                              flex: 3,
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () => _updateSetReps(index, -1),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        size: 14,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${set.actualReps}',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.titleMedium.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _updateSetReps(index, 1),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        size: 14,
                                        color: textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Completion check
                            InkWell(
                              onTap: () => _toggleSetCompleted(index),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: set.isCompleted
                                      ? AppColors.crimson
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: set.isCompleted
                                        ? AppColors.crimson
                                        : borderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: set.isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Add/Remove Set Buttons
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: _addSet,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Add Set',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.crimson,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                        if (_sets.length > 1) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _removeSet(_sets.length - 1),
                            icon: const Icon(Icons.remove, size: 16),
                            label: const Text(
                              'Remove Set',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: textMuted,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Integrated Rest Timer
                    RestTimerWidget(
                      initialSeconds: widget.state.settings.defaultRestSeconds,
                      enableSound: widget.state.settings.enableSound,
                      enableVibration: widget.state.settings.enableVibration,
                    ),
                  ],
                ),
              ),
            ),

            // Footer with Done / Complete buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.crimson,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: Text(
                        widget.exerciseLog.isCompleted
                            ? 'Save & Keep Completed'
                            : 'Mark Exercise Completed',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (widget.exerciseLog.isCompleted) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        await widget.state.undoExerciseCompletion(
                          widget.sessionId,
                          widget.exerciseLog.exerciseId,
                        );
                        if (mounted) nav.pop();
                      },
                      icon: const Icon(Icons.undo_rounded, size: 16),
                      label: const Text('Mark as Incomplete (Undo)'),
                      style: TextButton.styleFrom(foregroundColor: textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
