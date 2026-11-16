import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/exercise_definition.dart';
import '../../state/physique_state.dart';

class ExerciseLibrarySheet extends StatefulWidget {
  final PhysiqueState state;

  const ExerciseLibrarySheet({super.key, required this.state});

  @override
  State<ExerciseLibrarySheet> createState() => _ExerciseLibrarySheetState();
}

class _ExerciseLibrarySheetState extends State<ExerciseLibrarySheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscleGroup = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateCustomExerciseDialog() {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '8-12');
    final restCtrl = TextEditingController(text: '90');
    final instructionsCtrl = TextEditingController();
    String muscleGroup = MuscleGroups.chest;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('New Custom Exercise'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Exercise Name *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: muscleGroup,
                      decoration: const InputDecoration(labelText: 'Muscle Group'),
                      items: MuscleGroups.all.map((g) {
                        return DropdownMenuItem(value: g, child: Text(g));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => muscleGroup = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: setsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Default Sets'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            decoration: const InputDecoration(labelText: 'Target Reps'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: restCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rest (seconds)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: instructionsCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Notes or instructions'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) return;
                    final newEx = ExerciseDefinition(
                      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      muscleGroup: muscleGroup,
                      isCustom: true,
                      defaultSets: int.tryParse(setsCtrl.text) ?? 3,
                      defaultReps: repsCtrl.text.isNotEmpty ? repsCtrl.text : '8-12',
                      defaultRestSeconds: int.tryParse(restCtrl.text) ?? 90,
                      instructions: instructionsCtrl.text.trim(),
                    );
                    await widget.state.addCustomExercise(newEx);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    if (mounted) Navigator.of(context).pop(newEx);
                  },
                  child: const Text('Create & Select'),
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
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevatedColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final all = widget.state.allExercises;
    final query = _searchController.text.trim().toLowerCase();

    final filtered = all.where((ex) {
      final matchesGroup = _selectedMuscleGroup == 'All' || ex.muscleGroup == _selectedMuscleGroup;
      final matchesQuery = query.isEmpty ||
          ex.name.toLowerCase().contains(query) ||
          ex.muscleGroup.toLowerCase().contains(query);
      return matchesGroup && matchesQuery;
    }).toList();

    final groups = ['All', ...MuscleGroups.all];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exercise Library',
                      style: AppTypography.titleLarge.copyWith(color: textColor),
                    ),
                    Text(
                      'Choose an exercise or create your own',
                      style: AppTypography.bodyMedium.copyWith(color: textMuted, fontSize: 12),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _showCreateCustomExerciseDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Custom'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.crimson),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search exercise or muscle...',
                prefixIcon: Icon(Icons.search, size: 20, color: textMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: elevatedColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Muscle Group Filter Chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: groups.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) {
                final group = groups[i];
                final isSelected = _selectedMuscleGroup == group;
                return InkWell(
                  onTap: () => setState(() => _selectedMuscleGroup = group),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.crimson
                          : (isDark ? elevatedColor : elevatedColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.crimson : borderColor,
                      ),
                    ),
                    child: Text(
                      group,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white : textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          // Results List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 40, color: textMuted),
                        const SizedBox(height: 12),
                        Text('No exercises found', style: TextStyle(color: textMuted)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showCreateCustomExerciseDialog,
                          child: const Text('Create this custom exercise'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final ex = filtered[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        title: Row(
                          children: [
                            Text(
                              ex.name,
                              style: AppTypography.titleMedium.copyWith(
                                color: textColor,
                                fontSize: 14,
                              ),
                            ),
                            if (ex.isCustom) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.crimson.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CUSTOM',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.crimson,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${ex.muscleGroup} • ${ex.defaultSets} sets × ${ex.defaultReps} reps • ${ex.defaultRestSeconds}s rest',
                          style: AppTypography.bodyMedium.copyWith(
                            color: textMuted,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(Icons.add_circle_outline_rounded,
                            color: AppColors.crimson, size: 22),
                        onTap: () {
                          Navigator.of(context).pop(ex);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
