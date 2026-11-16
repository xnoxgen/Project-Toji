import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/physique_state.dart';
import 'edit_profile_screen.dart';
import 'backup_restore_dialog.dart';

class SettingsScreen extends StatelessWidget {
  final PhysiqueState state;

  const SettingsScreen({super.key, required this.state});

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete your workout history, custom exercises, measurements, and profile settings.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await state.resetAllData();
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been reset.')),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.crimson.withValues(alpha: 0.15),
                      child: Text(
                        state.profile.name.isNotEmpty
                            ? state.profile.name[0].toUpperCase()
                            : 'P',
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.crimson,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.profile.name,
                            style: AppTypography.titleLarge.copyWith(
                              color: textColor,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${state.profile.currentWeightKg.toStringAsFixed(1)} kg • ${state.profile.heightCm.toStringAsFixed(0)} cm • ${_formatGoal(state.profile.fitnessGoal)}',
                            style: AppTypography.bodyMedium.copyWith(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => EditProfileScreen(state: state),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      child: const Text('Edit', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionTitle('APPEARANCE', textMuted),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(
                        state.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.crimson,
                      ),
                      title: const Text('Dark Mode (Lamp Black)'),
                      subtitle: Text(
                        state.isDarkMode ? 'Lamp black & crimson theme' : 'Clean off-white & crimson theme',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                      value: state.isDarkMode,
                      activeThumbColor: AppColors.crimson,
                      onChanged: (val) {
                        state.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Timer Preferences Section
              _buildSectionTitle('REST TIMER PREFERENCES', textMuted),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.timer_outlined, color: AppColors.crimson),
                      title: const Text('Default Rest Duration'),
                      subtitle: Text('${state.settings.defaultRestSeconds} seconds',
                          style: TextStyle(color: textMuted, fontSize: 12)),
                      trailing: DropdownButton<int>(
                        value: state.settings.defaultRestSeconds,
                        underline: const SizedBox(),
                        dropdownColor: surfaceColor,
                        items: [30, 60, 90, 120, 180, 240, 300].map((s) {
                          return DropdownMenuItem(value: s, child: Text('${s}s'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            state.updateSettings(state.settings.copyWith(defaultRestSeconds: val));
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.volume_up_outlined, color: AppColors.crimson),
                      title: const Text('Timer Sound Alert'),
                      value: state.settings.enableSound,
                      activeThumbColor: AppColors.crimson,
                      onChanged: (val) {
                        state.updateSettings(state.settings.copyWith(enableSound: val));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded, color: AppColors.crimson),
                      title: const Text('Timer Haptic Vibration'),
                      value: state.settings.enableVibration,
                      activeThumbColor: AppColors.crimson,
                      onChanged: (val) {
                        state.updateSettings(state.settings.copyWith(enableVibration: val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Storage & Backups
              _buildSectionTitle('DATA & PERSISTENCE', textMuted),
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download_rounded, color: AppColors.crimson),
                      title: const Text('Export Backup (JSON)'),
                      subtitle: Text('Save complete workout logs, plans, and metrics',
                          style: TextStyle(color: textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BackupRestoreDialog(state: state, isExport: true),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.upload_rounded, color: AppColors.crimson),
                      title: const Text('Restore Backup (JSON)'),
                      subtitle: Text('Import database from a previous JSON export',
                          style: TextStyle(color: textMuted, fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BackupRestoreDialog(state: state, isExport: false),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                      title: const Text('Reset All Data', style: TextStyle(color: AppColors.error)),
                      subtitle: Text('Clear everything and start fresh',
                          style: TextStyle(color: textMuted, fontSize: 12)),
                      onTap: () => _showResetConfirmation(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // App Info
              _buildSectionTitle('ABOUT PHYSIQUE', textMuted),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.crimson,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PHYSIQUE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'v1.0.0 • Local-First Architecture',
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'A minimal, high-performance personal fitness tracker engineered for progressive overload, body measurement tracking, and transformation consistency.',
                      style: AppTypography.bodyMedium.copyWith(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _formatGoal(String goal) {
    switch (goal) {
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'fat_loss':
        return 'Fat Loss';
      case 'recomposition':
        return 'Body Recomp';
      case 'general_fitness':
        return 'Fitness';
      default:
        return goal;
    }
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
