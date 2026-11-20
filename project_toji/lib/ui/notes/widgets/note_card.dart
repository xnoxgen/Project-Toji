import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onTogglePin,
  });

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'personal':
        return Icons.person_rounded;
      case 'college':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'gym':
        return AppColors.crimson;
      case 'college':
        return const Color(0xFF3B82F6); // Blue
      case 'work':
        return const Color(0xFFF59E0B); // Amber
      case 'personal':
        return const Color(0xFF10B981); // Emerald
      default:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final dateStr = DateFormat('MMM d, yyyy').format(note.updatedAt);
    final catColor = _categoryColor(note.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: note.isPinned ? AppColors.crimson.withAlpha(120) : borderColor,
          width: note.isPinned ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Category chip + Pinned button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: catColor.withAlpha(60), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_categoryIcon(note.category), size: 12, color: catColor),
                          const SizedBox(width: 4),
                          Text(
                            note.category.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (note.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.crimson.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.push_pin_rounded, size: 11, color: AppColors.crimson),
                            const SizedBox(width: 3),
                            Text(
                              'PINNED',
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.crimson,
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        size: 18,
                        color: note.isPinned ? AppColors.crimson : textMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: note.isPinned ? 'Unpin note' : 'Pin note',
                      onPressed: onTogglePin,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Note Title
                if (note.title.isNotEmpty)
                  Text(
                    note.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      fontSize: 15,
                    ),
                  ),

                if (note.title.isNotEmpty && note.content.isNotEmpty)
                  const SizedBox(height: 6),

                // Note Content preview
                if (note.content.isNotEmpty)
                  Text(
                    note.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textMuted,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),

                const SizedBox(height: 12),

                // Footer: Date modified
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: textMuted),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        color: textMuted,
                      ),
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
