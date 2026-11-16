import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/workout_session.dart';

class WorkoutSummaryDialog extends StatelessWidget {
  final WorkoutSession session;
  final int streak;
  final VoidCallback onDismiss;
  final VoidCallback onUndo;

  const WorkoutSummaryDialog({
    super.key,
    required this.session,
    required this.streak,
    required this.onDismiss,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Dialog(
      backgroundColor: surfaceColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Crimson Badge Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.crimson.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.crimson, width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 36,
                  color: AppColors.crimson,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'WORKOUT FINISHED',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.crimson,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                session.workoutName,
                style: AppTypography.displayMedium.copyWith(
                  color: textColor,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Great discipline. Session logged and streak preserved.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: textMuted),
              ),
              const SizedBox(height: 24),

              // Statistics Grid
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          'EXERCISES',
                          '${session.completedExercisesCount}/${session.totalExercisesCount}',
                          textColor,
                          textMuted,
                        ),
                        Container(width: 1, height: 36, color: borderColor),
                        _buildStat(
                          'TOTAL SETS',
                          '${session.totalCompletedSets}',
                          textColor,
                          textMuted,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          'VOLUME',
                          session.totalVolumeKg > 0
                              ? '${session.totalVolumeKg.toStringAsFixed(0)} kg'
                              : 'Bodyweight',
                          textColor,
                          textMuted,
                        ),
                        Container(width: 1, height: 36, color: borderColor),
                        _buildStat(
                          'STREAK',
                          '$streak days',
                          AppColors.crimson,
                          textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Return to Dashboard',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onUndo,
                style: TextButton.styleFrom(
                  foregroundColor: textMuted,
                ),
                child: const Text('Undo Workout Completion',
                    style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color valColor, Color labelColor) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: labelColor,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: valColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

