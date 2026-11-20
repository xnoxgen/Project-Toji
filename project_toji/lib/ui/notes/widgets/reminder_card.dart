import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/reminder_model.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
  });

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.crimson;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.warning;
    }
  }

  String _advanceNotificationLabel(int minutes) {
    if (minutes <= 0) return 'At time';
    if (minutes == 5) return '5m before';
    if (minutes == 10) return '10m before';
    if (minutes == 15) return '15m before';
    return '${minutes}m before';
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

    final priColor = _priorityColor(reminder.priority);
    final dateStr = DateFormat('EEE, MMM d • hh:mm a')
        .format(reminder.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: reminder.isOverdue
              ? AppColors.crimson.withAlpha(120)
              : borderColor,
          width: reminder.isOverdue ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: reminder.isCompleted
                          ? AppColors.crimson
                          : Colors.transparent,
                      border: Border.all(
                        color: reminder.isCompleted
                            ? AppColors.crimson
                            : (reminder.isOverdue
                                  ? AppColors.crimson
                                  : textMuted),
                        width: 2,
                      ),
                    ),
                    child: reminder.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row: Priority + Advance notice + Overdue
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: priColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: priColor.withAlpha(70),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${reminder.priority.toUpperCase()} PRIORITY',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: priColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (reminder.isNotificationEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications_active_rounded,
                                    size: 10,
                                    color: AppColors.crimson,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _advanceNotificationLabel(
                                      reminder.advanceMinutes,
                                    ),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (reminder.isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.crimson.withAlpha(30),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: AppColors.crimson.withAlpha(80),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 10,
                                    color: AppColors.crimson,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'OVERDUE',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.crimson,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        reminder.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: reminder.isCompleted ? textMuted : textPrimary,
                          decoration: reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      // Associated Note Link Tag
                      if (reminder.noteTitle != null &&
                          reminder.noteTitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.link_rounded,
                              size: 12,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Note: ${reminder.noteTitle}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.crimson,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Description
                      if (reminder.description != null &&
                          reminder.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            color: textMuted,
                            fontSize: 12,
                            decoration: reminder.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Scheduled Date/Time
                      Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            size: 13,
                            color: reminder.isOverdue
                                ? AppColors.crimson
                                : textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateStr,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 11,
                              fontWeight: reminder.isOverdue
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: reminder.isOverdue
                                  ? AppColors.crimson
                                  : textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing actions: Edit & Delete
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: textMuted,
                      tooltip: 'Edit reminder',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: onEdit,
                    ),
                    const SizedBox(height: 6),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      color: textMuted,
                      tooltip: 'Delete reminder',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
