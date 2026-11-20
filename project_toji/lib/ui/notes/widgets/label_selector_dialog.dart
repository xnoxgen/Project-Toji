import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/label_model.dart';
import '../../../state/notes_state.dart';
import 'label_chip.dart';

class LabelSelectorDialog extends StatefulWidget {
  final NotesState notesState;
  final List<String> initialSelectedIds;
  final ValueChanged<List<String>> onSelectionChanged;

  const LabelSelectorDialog({
    super.key,
    required this.notesState,
    required this.initialSelectedIds,
    required this.onSelectionChanged,
  });

  @override
  State<LabelSelectorDialog> createState() => _LabelSelectorDialogState();
}

class _LabelSelectorDialogState extends State<LabelSelectorDialog> {
  late List<String> _selectedIds;
  bool _isCreatingNew = false;
  final TextEditingController _newLabelController = TextEditingController();
  int _selectedColor = LabelModel.defaultColors[0];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.initialSelectedIds);
  }

  @override
  void dispose() {
    _newLabelController.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _createLabel() async {
    final name = _newLabelController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Label name cannot be empty');
      return;
    }
    if (widget.notesState.isLabelNameDuplicate(name)) {
      setState(() => _errorMessage = 'A label with this name already exists');
      return;
    }

    final success = await widget.notesState.addLabel(name, _selectedColor);
    if (success) {
      final created = widget.notesState.labels.last;
      setState(() {
        _selectedIds.add(created.id);
        _isCreatingNew = false;
        _newLabelController.clear();
        _errorMessage = null;
      });
    }
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

    final labels = widget.notesState.labels;

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.label_rounded,
                  color: AppColors.crimson,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Manage Note Labels',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: textMuted,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Existing Labels List
            if (labels.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No labels created yet.',
                  style: TextStyle(color: textMuted),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: labels.map((l) {
                      final isSel = _selectedIds.contains(l.id);
                      return LabelChipWidget(
                        label: l,
                        isSelected: isSel,
                        onTap: () => _toggle(l.id),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // Add New Label Form / Button
            if (!_isCreatingNew)
              OutlinedButton.icon(
                onPressed: () => setState(() => _isCreatingNew = true),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Create New Label'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.crimson,
                  side: const BorderSide(color: AppColors.crimson),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _newLabelController,
                    style: TextStyle(color: textPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter label name...',
                      hintStyle: TextStyle(
                        color: textMuted.withAlpha(120),
                        fontSize: 13,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.lightBackground,
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.crimson),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Color selection dots
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: LabelModel.defaultColors.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final c = LabelModel.defaultColors[i];
                        final isChosen = _selectedColor == c;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = c),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isChosen
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isChosen
                                  ? [
                                      BoxShadow(
                                        color: Color(c).withAlpha(150),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() {
                          _isCreatingNew = false;
                          _errorMessage = null;
                        }),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: textMuted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _createLabel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimson,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Save Label'),
                      ),
                    ],
                  ),
                ],
              ),

            const SizedBox(height: 16),
            // Apply Selection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelectionChanged(_selectedIds);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
