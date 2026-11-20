import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? initialNote;
  final ValueChanged<NoteModel> onSave;
  final ValueChanged<String>? onDelete;

  const NoteEditorScreen({
    super.key,
    this.initialNote,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  late bool _isPinned;
  bool _hasChanges = false;

  final List<String> _categories = [
    'Personal',
    'College',
    'Work',
    'Gym',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title ?? '');
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
    _selectedCategory = widget.initialNote?.category ?? 'Personal';
    _isPinned = widget.initialNote?.isPinned ?? false;

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final now = DateTime.now();
    final note = widget.initialNote?.copyWith(
          title: title.isEmpty ? 'Untitled Note' : title,
          content: content,
          category: _selectedCategory,
          isPinned: _isPinned,
          updatedAt: now,
        ) ??
        NoteModel(
          id: 'note_${now.millisecondsSinceEpoch}',
          title: title.isEmpty ? 'Untitled Note' : title,
          content: content,
          category: _selectedCategory,
          isPinned: _isPinned,
          createdAt: now,
          updatedAt: now,
        );

    widget.onSave(note);
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Text(
            'Delete Note?',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This action cannot be undone. Are you sure you want to delete this note?',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.crimson, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      if (widget.initialNote != null && widget.onDelete != null) {
        widget.onDelete!(widget.initialNote!.id);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _saveAndExit();
        }
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: textPrimary,
            onPressed: _saveAndExit,
          ),
          actions: [
            // Pin Toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.crimson : textMuted,
              ),
              tooltip: _isPinned ? 'Unpin note' : 'Pin note',
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _hasChanges = true;
                });
              },
            ),
            // Delete button (only when editing existing note)
            if (widget.initialNote != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.crimson,
                tooltip: 'Delete note',
                onPressed: _confirmDelete,
              ),
            // Save Button
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: ElevatedButton.icon(
                onPressed: _saveAndExit,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimson,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Category selector bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: borderColor, width: 0.8)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Category:',
                      style: AppTypography.labelSmall.copyWith(
                        color: textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSel = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedCategory = cat;
                                      _hasChanges = true;
                                    });
                                  }
                                },
                                selectedColor: AppColors.crimson.withAlpha(40),
                                backgroundColor: surfaceColor,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isSel ? AppColors.crimson : textMuted,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                ),
                                side: BorderSide(
                                  color: isSel ? AppColors.crimson : borderColor,
                                  width: isSel ? 1.5 : 1,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title input
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: TextField(
                  controller: _titleController,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    fontSize: 22,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Note Title',
                    hintStyle: AppTypography.titleLarge.copyWith(
                      color: textMuted.withAlpha(120),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const Divider(height: 1),

              // Content input
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                      height: 1.6,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your note, ideas or workout thoughts...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: textMuted.withAlpha(120),
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
