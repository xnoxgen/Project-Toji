import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CategoryFilterChips extends StatelessWidget {
  final String? selectedCategory; // null = All
  final ValueChanged<String?> onSelectCategory;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  static const List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Personal', 'icon': Icons.person_rounded},
    {'name': 'College', 'icon': Icons.school_rounded},
    {'name': 'Work', 'icon': Icons.work_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Other', 'icon': Icons.label_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((cat) {
          final name = cat['name'] as String;
          final icon = cat['icon'] as IconData;
          final isSelected =
              (selectedCategory == null && name == 'All') ||
              (selectedCategory?.toLowerCase() == name.toLowerCase());

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  if (name == 'All') {
                    onSelectCategory(null);
                  } else {
                    onSelectCategory(isSelected ? null : name);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.crimson : surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.crimson : borderColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: AppTypography.labelSmall.copyWith(
                          color: isSelected ? Colors.white : textMuted,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
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
    );
  }
}
