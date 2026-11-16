import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/physique_state.dart';
import 'edit_profile_screen.dart';
import '../progress/add_measurement_dialog.dart';

class ProfileOverviewScreen extends StatelessWidget {
  final PhysiqueState state;

  const ProfileOverviewScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevatedColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final p = state.profile;

    final metrics = [
      {
        'label': 'Body Weight',
        'current': state.getLatestMeasurement('weight') ?? p.currentWeightKg,
        'target': p.targetWeightKg,
        'unit': 'kg',
        'type': 'weight',
        'isLoss': (p.targetWeightKg != null && p.targetWeightKg! < p.currentWeightKg),
      },
      {
        'label': 'Waist',
        'current': state.getLatestMeasurement('waist') ?? p.waistCm,
        'target': p.targetWaistCm,
        'unit': 'cm',
        'type': 'waist',
        'isLoss': true,
      },
      {
        'label': 'Chest',
        'current': state.getLatestMeasurement('chest') ?? p.chestCm,
        'target': p.targetChestCm,
        'unit': 'cm',
        'type': 'chest',
        'isLoss': false,
      },
      {
        'label': 'Biceps',
        'current': state.getLatestMeasurement('biceps') ?? p.bicepsCm,
        'target': p.targetBicepsCm,
        'unit': 'cm',
        'type': 'biceps',
        'isLoss': false,
      },
      {
        'label': 'Shoulders',
        'current': state.getLatestMeasurement('shoulders') ?? p.shoulderCm,
        'target': p.targetShoulderCm,
        'unit': 'cm',
        'type': 'shoulders',
        'isLoss': false,
      },
      {
        'label': 'Forearms',
        'current': state.getLatestMeasurement('forearms') ?? p.forearmCm,
        'target': p.targetForearmCm,
        'unit': 'cm',
        'type': 'forearms',
        'isLoss': false,
      },
      {
        'label': 'Thighs',
        'current': state.getLatestMeasurement('thighs') ?? p.thighCm,
        'target': p.targetThighCm,
        'unit': 'cm',
        'type': 'thighs',
        'isLoss': false,
      },
      {
        'label': 'Calves',
        'current': state.getLatestMeasurement('calves') ?? p.calfCm,
        'target': p.targetCalfCm,
        'unit': 'cm',
        'type': 'calves',
        'isLoss': false,
      },
      {
        'label': 'Neck',
        'current': state.getLatestMeasurement('neck') ?? p.neckCm,
        'target': p.targetNeckCm,
        'unit': 'cm',
        'type': 'neck',
        'isLoss': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Physique Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile & Targets',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => EditProfileScreen(state: state),
                ),
              );
            },
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
                // Athlete Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: AppColors.crimson.withValues(alpha: 0.15),
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : 'P',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.crimson,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.name,
                        style: AppTypography.titleLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.age} years • ${p.sex} • ${p.heightCm.toStringAsFixed(0)} cm • ${p.currentWeightKg.toStringAsFixed(1)} kg',
                        style: AppTypography.bodyMedium.copyWith(color: textMuted),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.crimson.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.crimson.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _formatGoal(p.fitnessGoal).toUpperCase(),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.crimson,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Target Physique Vision Card
                if (p.targetPhysiqueDescription.isNotEmpty) ...[
                  Container(
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
                          children: [
                            const Icon(Icons.flag_outlined, size: 16, color: AppColors.crimson),
                            const SizedBox(width: 6),
                            Text(
                              'TARGET PHYSIQUE VISION',
                              style: AppTypography.labelSmall.copyWith(
                                color: textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${p.targetPhysiqueDescription}"',
                          style: AppTypography.bodyLarge.copyWith(
                            color: textColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT VS TARGET MEASUREMENTS',
                      style: AppTypography.labelSmall.copyWith(
                        color: textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AddMeasurementDialog(state: state),
                        );
                      },
                      child: Text(
                        '+ Log Measurement',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Measurement Comparison Cards List
                ...metrics.map((m) {
                  final current = m['current'] as double?;
                  final target = m['target'] as double?;
                  final unit = m['unit'] as String;
                  final label = m['label'] as String;

                  if (current == null && target == null) {
                    return const SizedBox.shrink();
                  }

                  double? delta;
                  if (current != null && target != null) {
                    delta = target - current;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                              style: AppTypography.titleMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (delta != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: elevatedColor,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Text(
                                  delta == 0
                                      ? 'GOAL REACHED ✓'
                                      : '${delta > 0 ? "+" : ""}${delta.toStringAsFixed(1)} $unit remaining',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: delta == 0 ? AppColors.success : AppColors.crimson,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current',
                                  style: AppTypography.labelSmall.copyWith(color: textMuted, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  current != null ? '${current.toStringAsFixed(1)} $unit' : '--',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Icon(Icons.arrow_forward_rounded, size: 16, color: textMuted),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Target',
                                  style: AppTypography.labelSmall.copyWith(color: textMuted, fontSize: 10),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  target != null ? '${target.toStringAsFixed(1)} $unit' : 'Not set',
                                  style: AppTypography.titleLarge.copyWith(
                                    color: target != null ? AppColors.crimson : textMuted,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Edit Button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => EditProfileScreen(state: state),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Measurements & Goals'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatGoal(String goal) {
    switch (goal) {
      case 'muscle_gain':
        return 'Muscle Gain (Hypertrophy)';
      case 'fat_loss':
        return 'Fat Loss (Cutting)';
      case 'recomposition':
        return 'Body Recomposition';
      case 'general_fitness':
        return 'General Fitness';
      default:
        return goal;
    }
  }
}
