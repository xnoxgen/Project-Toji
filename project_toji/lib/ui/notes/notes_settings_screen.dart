import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/label_model.dart';
import '../../data/services/reminder_notification_service.dart';
import '../../state/notes_state.dart';

class NotesSettingsScreen extends StatefulWidget {
  final NotesState notesState;

  const NotesSettingsScreen({super.key, required this.notesState});

  @override
  State<NotesSettingsScreen> createState() => _NotesSettingsScreenState();
}

class _NotesSettingsScreenState extends State<NotesSettingsScreen>
    with WidgetsBindingObserver {
  bool _notificationsAllowed = true;
  bool _exactAlarmsAvailable = true;
  int _pendingCount = 0;
  String _timeZone = '';
  bool _isSendingTest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotificationStatus();
    }
  }

  Future<void> _refreshNotificationStatus() async {
    final notifs = await ReminderNotificationService()
        .areNotificationsEnabled();
    final exact = await ReminderNotificationService().canScheduleExactAlarms();
    final pending = await ReminderNotificationService()
        .getPendingNotifications();
    if (mounted) {
      setState(() {
        _notificationsAllowed = notifs;
        _exactAlarmsAvailable = exact;
        _pendingCount = pending.length;
        _timeZone = ReminderNotificationService().deviceTimeZone;
      });
    }
  }

  Future<void> _triggerTestAlert() async {
    setState(() => _isSendingTest = true);
    final success = await ReminderNotificationService().sendTestNotification(
      delaySeconds: 10,
    );
    if (!mounted) return;
    setState(() => _isSendingTest = false);

    _refreshNotificationStatus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.crimson,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success
                    ? 'Test alert scheduled in 10s! Keep device active to view in shade.'
                    : 'Failed to schedule test alert. Check notification permissions.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _showPendingNotificationsDialog() async {
    final pending = await ReminderNotificationService()
        .getPendingNotifications();
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Pending Scheduled Alerts (${pending.length})',
          style: AppTypography.titleMedium.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: pending.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No alerts currently scheduled in Android AlarmManager.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  separatorBuilder: (_, _) => const Divider(height: 12),
                  itemBuilder: (_, i) {
                    final item = pending[i];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(
                        Icons.alarm_rounded,
                        color: AppColors.crimson,
                        size: 20,
                      ),
                      title: Text(
                        item.title ?? 'Reminder #${item.id}',
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${item.id} • ${item.body ?? 'No details'}',
                        style: TextStyle(color: textMuted, fontSize: 11),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openCreateOrEditLabelDialog([LabelModel? labelToEdit]) {
    final nameController = TextEditingController(text: labelToEdit?.name ?? '');
    int chosenColor = labelToEdit?.colorValue ?? LabelModel.defaultColors[0];
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final surfaceColor = isDark
                ? AppColors.darkSurface
                : AppColors.lightSurface;
            final borderColor = isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder;
            final textPrimary = isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary;
            final textMuted = isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary;

            return Dialog(
              backgroundColor: surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      labelToEdit == null ? 'Create New Label' : 'Edit Label',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name input
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      style: TextStyle(color: textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Label Name',
                        labelStyle: TextStyle(color: textMuted),
                        hintText: 'e.g. Work, Ideas, Study',
                        hintStyle: TextStyle(color: textMuted.withAlpha(120)),
                        errorText: errorText,
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkBackground
                            : AppColors.lightBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.crimson,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color palette
                    Text(
                      'Label Color',
                      style: AppTypography.labelSmall.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: LabelModel.defaultColors.map((colorVal) {
                        final isSelected = chosenColor == colorVal;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              chosenColor = colorVal;
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(colorVal).withAlpha(150),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: textMuted),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            if (name.isEmpty) {
                              setDialogState(() {
                                errorText = 'Label name cannot be empty';
                              });
                              return;
                            }
                            if (widget.notesState.isLabelNameDuplicate(
                              name,
                              excludeId: labelToEdit?.id,
                            )) {
                              setDialogState(() {
                                errorText = 'Label "$name" already exists';
                              });
                              return;
                            }

                            if (labelToEdit == null) {
                              await widget.notesState.addLabel(
                                name,
                                chosenColor,
                              );
                            } else {
                              await widget.notesState.updateLabel(
                                labelToEdit.copyWith(
                                  name: name,
                                  colorValue: chosenColor,
                                ),
                              );
                            }
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.crimson,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(labelToEdit == null ? 'Create' : 'Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteLabel(LabelModel label) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          title: Text(
            'Delete Label "${label.name}"?',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Deleting this label will remove it from all associated notes. The notes themselves will not be deleted.',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await widget.notesState.deleteLabel(label.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notes Settings',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.notesState,
        builder: (context, _) {
          final labels = widget.notesState.labels;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Header description
              Text(
                'CUSTOM LABELS',
                style: AppTypography.labelSmall.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.crimson,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Create and manage custom colored tags to organize your thoughts, routines, and study notes.',
                style: AppTypography.bodyMedium.copyWith(color: textMuted),
              ),
              const SizedBox(height: 16),

              // Labels Container
              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    ...labels.asMap().entries.map((entry) {
                      final i = entry.key;
                      final label = entry.value;
                      final color = Color(label.colorValue);

                      return Column(
                        children: [
                          if (i > 0) Divider(height: 1, color: borderColor),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            title: Text(
                              label.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${widget.notesState.notes.where((n) => n.labelIds.contains(label.id)).length} notes tagged',
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  color: textMuted,
                                  tooltip: 'Edit label',
                                  onPressed: () =>
                                      _openCreateOrEditLabelDialog(label),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                  ),
                                  color: AppColors.crimson,
                                  tooltip: 'Delete label',
                                  onPressed: () => _confirmDeleteLabel(label),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    if (labels.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No labels exist. Create one below!',
                          style: TextStyle(color: textMuted),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Add Label Button
              ElevatedButton.icon(
                onPressed: () => _openCreateOrEditLabelDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add New Label'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),

              const SizedBox(height: 32),

              // Permission & Notification Status Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PERMISSION & NOTIFICATION STATUS',
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: AppColors.crimson,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    color: textMuted,
                    tooltip: 'Refresh Status',
                    onPressed: _refreshNotificationStatus,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Notifications Row
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _notificationsAllowed
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _notificationsAllowed
                                    ? 'Allowed (System active)'
                                    : 'Blocked / Disabled in OS',
                                style: TextStyle(
                                  color: _notificationsAllowed
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await ReminderNotificationService()
                                .openAppNotificationSettings();
                            _refreshNotificationStatus();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.crimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 16, color: borderColor),

                    // Exact Alarms Row
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _exactAlarmsAvailable
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Exact Alarms',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _exactAlarmsAvailable
                                    ? 'Available (AlarmManager exact timing)'
                                    : 'Restricted (Delivery may have slight jitter)',
                                style: TextStyle(
                                  color: _exactAlarmsAvailable
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFF59E0B),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_exactAlarmsAvailable)
                          TextButton(
                            onPressed: () async {
                              await ReminderNotificationService()
                                  .requestExactAlarmsPermission();
                              _refreshNotificationStatus();
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Grant',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.crimson,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Divider(height: 16, color: borderColor),

                    // Timezone Row
                    _buildStatRow(
                      'Timezone',
                      _timeZone.isNotEmpty ? _timeZone : 'Device System',
                      textPrimary,
                      textMuted,
                    ),
                    Divider(height: 16, color: borderColor),

                    // Scheduled Alerts in AlarmManager
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scheduled in AlarmManager',
                          style: TextStyle(color: textMuted, fontSize: 13),
                        ),
                        Row(
                          children: [
                            Text(
                              '$_pendingCount active',
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            if (_pendingCount > 0) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _showPendingNotificationsDialog,
                                child: const Icon(
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: AppColors.crimson,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Diagnostics Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isSendingTest
                                ? null
                                : _triggerTestAlert,
                            icon: _isSendingTest
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.crimson,
                                    ),
                                  )
                                : const Icon(Icons.alarm_add_rounded, size: 16),
                            label: const Text(
                              'Test Alert (10s)',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textPrimary,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showPendingNotificationsDialog,
                            icon: const Icon(Icons.list_alt_rounded, size: 16),
                            label: const Text(
                              'Inspect Alerts',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textPrimary,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Statistics Section
              Text(
                'MODULE OVERVIEW',
                style: AppTypography.labelSmall.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      'Total Notes',
                      '${widget.notesState.notes.length}',
                      textPrimary,
                      textMuted,
                    ),
                    Divider(height: 16, color: borderColor),
                    _buildStatRow(
                      'Pinned Notes',
                      '${widget.notesState.pinnedNotes.length}',
                      textPrimary,
                      textMuted,
                    ),
                    Divider(height: 16, color: borderColor),
                    _buildStatRow(
                      'Active Labels',
                      '${labels.length}',
                      textPrimary,
                      textMuted,
                    ),
                    Divider(height: 16, color: borderColor),
                    _buildStatRow(
                      'Upcoming Reminders',
                      '${widget.notesState.upcomingReminders.length}',
                      textPrimary,
                      textMuted,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatRow(
    String title,
    String value,
    Color textPrimary,
    Color textMuted,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textMuted, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
