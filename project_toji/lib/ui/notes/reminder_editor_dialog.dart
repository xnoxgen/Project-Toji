import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/reminder_model.dart';
import '../../data/services/reminder_notification_service.dart';

class ReminderEditorDialog extends StatefulWidget {
  final ReminderModel? initialReminder;
  final String? associatedNoteId;
  final String? associatedNoteTitle;
  final ValueChanged<ReminderModel> onSave;
  final ValueChanged<int>? onDelete;

  const ReminderEditorDialog({
    super.key,
    this.initialReminder,
    this.associatedNoteId,
    this.associatedNoteTitle,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<ReminderEditorDialog> createState() => _ReminderEditorDialogState();
}

class _ReminderEditorDialogState extends State<ReminderEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _priority;
  late bool _isNotificationEnabled;
  late int _advanceMinutes;
  bool _isCustomMinutes = false;
  late TextEditingController _customMinutesController;
  bool _hasCheckedPermission = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialReminder?.title ?? widget.associatedNoteTitle ?? '',
    );
    _descController = TextEditingController(
      text: widget.initialReminder?.description ?? '',
    );

    if (widget.initialReminder != null) {
      _selectedDate = widget.initialReminder!.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.initialReminder!.dateTime);
      _priority = widget.initialReminder!.priority;
      _isNotificationEnabled = widget.initialReminder!.isNotificationEnabled;
      _advanceMinutes = widget.initialReminder!.advanceMinutes;
      if (![0, 5, 10, 15].contains(_advanceMinutes)) {
        _isCustomMinutes = true;
      }
    } else {
      final now = DateTime.now().add(const Duration(hours: 1));
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedTime = TimeOfDay(
        hour: now.hour,
        minute: (now.minute / 5).ceil() * 5,
      );
      _priority = 'medium';
      _isNotificationEnabled = true;
      _advanceMinutes = 10; // Default: 10 mins before
    }

    _customMinutesController = TextEditingController(
      text: _advanceMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _customMinutesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: AppColors.crimson),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: AppColors.crimson),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<bool> _handleNotificationPermissionRequest() async {
    final service = ReminderNotificationService();
    final isEnabled = await service.areNotificationsEnabled();
    if (isEnabled) {
      _hasCheckedPermission = true;
      await _handleExactAlarmPermission();
      return true;
    }

    if (!mounted) return false;

    // Show rationale dialog explaining why permission is required
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildPermissionRationaleDialog(
        title: 'Enable Notifications',
        icon: Icons.notifications_active_rounded,
        message: 'Allow notifications to receive your scheduled reminders.',
        actionLabel: 'Allow',
      ),
    );

    if (shouldRequest != true) {
      return false;
    }

    final granted = await service.requestNotificationsPermission();
    if (!mounted) return false;

    if (!granted) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (ctx) => _buildPermissionRationaleDialog(
          title: 'Notification Permission Denied',
          icon: Icons.notifications_off_rounded,
          message: 'Notifications are currently disabled. Please enable notifications in App Settings to receive reminder alerts.',
          actionLabel: 'Open Settings',
        ),
      );

      if (openSettings == true) {
        await service.openAppNotificationSettings();
      }
      return false;
    }

    _hasCheckedPermission = true;
    await _handleExactAlarmPermission();
    return true;
  }

  Future<void> _handleExactAlarmPermission() async {
    final service = ReminderNotificationService();
    final canExact = await service.canScheduleExactAlarms();
    if (canExact) return;

    if (!mounted) return;

    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildPermissionRationaleDialog(
        title: 'Exact Alarm Access',
        icon: Icons.alarm_rounded,
        message: 'Allow exact alarms so your reminders can notify you at the scheduled time.',
        actionLabel: 'Grant Access',
        cancelLabel: 'Use Standard',
      ),
    );

    if (shouldOpen == true) {
      await service.requestExactAlarmsPermission();
      final granted = await service.canScheduleExactAlarms();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF1C1C1C),
            content: Text(
              'Exact alarm access not granted. Reminders will use standard notification timing.',
              style: TextStyle(color: Color(0xFFF5F5F5), fontSize: 12),
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildPermissionRationaleDialog({
    required String title,
    required IconData icon,
    required String message,
    required String actionLabel,
    String cancelLabel = 'Cancel',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.crimson.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.crimson, size: 28),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTypography.titleMedium.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textMuted, fontSize: 13, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel, style: TextStyle(color: textMuted)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.crimson,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_isNotificationEnabled && !_hasCheckedPermission) {
      final allowed = await _handleNotificationPermissionRequest();
      if (!allowed) {
        _isNotificationEnabled = false;
      }
    }

    if (!mounted) return;
    final nav = Navigator.of(context);

    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    int finalAdvance = _advanceMinutes;
    if (_isCustomMinutes) {
      final parsed = int.tryParse(_customMinutesController.text.trim());
      if (parsed != null && parsed >= 0) {
        finalAdvance = parsed;
      }
    }

    final now = DateTime.now();
    final reminder =
        widget.initialReminder?.copyWith(
          title: title,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          dateTime: scheduledDateTime,
          priority: _priority,
          isNotificationEnabled: _isNotificationEnabled,
          advanceMinutes: finalAdvance,
          noteId: widget.associatedNoteId ?? widget.initialReminder?.noteId,
          noteTitle:
              widget.associatedNoteTitle ?? widget.initialReminder?.noteTitle,
        ) ??
        ReminderModel(
          id: (now.millisecondsSinceEpoch ~/ 1000) % 1000000,
          title: title,
          description: _descController.text.trim().isEmpty
              ? null
              : _descController.text.trim(),
          dateTime: scheduledDateTime,
          priority: _priority,
          isCompleted: false,
          isNotificationEnabled: _isNotificationEnabled,
          advanceMinutes: finalAdvance,
          noteId: widget.associatedNoteId,
          noteTitle: widget.associatedNoteTitle,
          createdAt: now,
        );

    widget.onSave(reminder);
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
    final timeFormatted = _selectedTime.format(context);

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.crimson.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: AppColors.crimson,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.initialReminder == null
                          ? 'New Reminder'
                          : 'Edit Reminder',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  if (widget.initialReminder != null && widget.onDelete != null)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.crimson,
                        size: 20,
                      ),
                      onPressed: () {
                        widget.onDelete!(widget.initialReminder!.id);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Title input
              TextField(
                controller: _titleController,
                autofocus: widget.initialReminder == null,
                style: TextStyle(color: textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Reminder Title',
                  labelStyle: TextStyle(color: textMuted),
                  hintText: 'e.g. Protein shake, Mobility session',
                  hintStyle: TextStyle(color: textMuted.withAlpha(120)),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
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
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // Description input
              TextField(
                controller: _descController,
                maxLines: 2,
                style: TextStyle(color: textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Notes / Description (Optional)',
                  labelStyle: TextStyle(color: textMuted),
                  hintText: 'Additional details or instructions',
                  hintStyle: TextStyle(color: textMuted.withAlpha(120)),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
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
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              // Date & Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateFormatted,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                timeFormatted,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Notification Toggle
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isNotificationEnabled
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                      size: 18,
                      color: _isNotificationEnabled
                          ? AppColors.crimson
                          : textMuted,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Alert Notification',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          Text(
                            'Triggers system notification on your device',
                            style: TextStyle(fontSize: 11, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isNotificationEnabled,
                      activeTrackColor: AppColors.crimson,
                      activeThumbColor: Colors.white,
                      onChanged: (val) async {
                        if (val) {
                          final allowed =
                              await _handleNotificationPermissionRequest();
                          if (mounted) {
                            setState(() {
                              _isNotificationEnabled = allowed;
                            });
                          }
                        } else {
                          setState(() {
                            _isNotificationEnabled = false;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Advance Notification Options (only if notifications enabled)
              if (_isNotificationEnabled) ...[
                const SizedBox(height: 14),
                Text(
                  'Advance Notification',
                  style: AppTypography.labelSmall.copyWith(
                    color: textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _advanceOptionChip(0, 'At time'),
                    _advanceOptionChip(5, '5m before'),
                    _advanceOptionChip(10, '10m before'),
                    _advanceOptionChip(15, '15m before'),
                    _customAdvanceOptionChip(),
                  ],
                ),
                if (_isCustomMinutes) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: _customMinutesController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Minutes',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed != null) {
                              _advanceMinutes = parsed;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'minutes before reminder time',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 14),

              // Priority Selection
              Text(
                'Priority Level',
                style: AppTypography.labelSmall.copyWith(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _priorityChip('low', 'Low', const Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  _priorityChip('medium', 'Medium', AppColors.warning),
                  const SizedBox(width: 8),
                  _priorityChip('high', 'High', AppColors.crimson),
                ],
              ),
              const SizedBox(height: 22),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: textMuted)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crimson,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      widget.initialReminder == null
                          ? 'Set Reminder'
                          : 'Update',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _advanceOptionChip(int minutes, String label) {
    final isSelected = !_isCustomMinutes && _advanceMinutes == minutes;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _isCustomMinutes = false;
            _advanceMinutes = minutes;
          });
        }
      },
      selectedColor: AppColors.crimson.withAlpha(35),
      labelStyle: TextStyle(
        fontSize: 11,
        color: isSelected
            ? AppColors.crimson
            : Theme.of(context).textTheme.bodySmall?.color,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected
            ? AppColors.crimson
            : Theme.of(context).dividerColor.withAlpha(70),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _customAdvanceOptionChip() {
    return ChoiceChip(
      label: const Text('Custom...'),
      selected: _isCustomMinutes,
      onSelected: (selected) {
        setState(() {
          _isCustomMinutes = true;
        });
      },
      selectedColor: AppColors.crimson.withAlpha(35),
      labelStyle: TextStyle(
        fontSize: 11,
        color: _isCustomMinutes
            ? AppColors.crimson
            : Theme.of(context).textTheme.bodySmall?.color,
        fontWeight: _isCustomMinutes ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: _isCustomMinutes
            ? AppColors.crimson
            : Theme.of(context).dividerColor.withAlpha(70),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  Widget _priorityChip(String key, String label, Color color) {
    final isSelected = _priority.toLowerCase() == key;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _priority = key;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(35) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color
                  : Theme.of(context).dividerColor.withAlpha(70),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? color
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ),
    );
  }
}
