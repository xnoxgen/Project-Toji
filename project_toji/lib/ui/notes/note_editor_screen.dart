import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/note_model.dart';
import '../../data/models/reminder_model.dart';
import '../../state/notes_state.dart';
import 'reminder_editor_dialog.dart';
import 'widgets/formatting_toolbar.dart';
import 'widgets/label_chip.dart';
import 'widgets/label_selector_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteModel? initialNote;
  final NotesState notesState;
  final ValueChanged<NoteModel> onSave;
  final ValueChanged<String>? onDelete;

  const NoteEditorScreen({
    super.key,
    this.initialNote,
    required this.notesState,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;

  late List<String> _selectedLabelIds;
  late bool _isPinned;
  int? _reminderId;
  DateTime? _reminderDateTime;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialNote?.title ?? '',
    );
    _selectedLabelIds = List<String>.from(widget.initialNote?.labelIds ?? []);
    _isPinned = widget.initialNote?.isPinned ?? false;
    _reminderId = widget.initialNote?.reminderId;
    _reminderDateTime = widget.initialNote?.reminderDateTime;

    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    // Initialize Quill Document
    Document document;
    if (widget.initialNote?.contentJson != null &&
        widget.initialNote!.contentJson!.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(widget.initialNote!.contentJson!);
        document = Document.fromJson(decoded as List<dynamic>);
      } catch (_) {
        document = _fallbackDocument(widget.initialNote?.content ?? '');
      }
    } else if (widget.initialNote?.content != null &&
        widget.initialNote!.content.isNotEmpty) {
      document = _fallbackDocument(widget.initialNote!.content);
    } else {
      document = Document();
    }

    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _titleController.addListener(_onChanged);
    _quillController.addListener(_onChanged);
  }

  Document _fallbackDocument(String plainText) {
    final doc = Document();
    if (plainText.isNotEmpty) {
      doc.insert(0, plainText);
    }
    return doc;
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  void _saveAndExit() {
    final title = _titleController.text.trim();
    final plainText = _quillController.document.toPlainText().trim();
    final deltaJson = jsonEncode(_quillController.document.toDelta().toJson());

    // If completely empty, just close
    if (title.isEmpty && plainText.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    final now = DateTime.now();
    final note =
        widget.initialNote?.copyWith(
          title: title.isEmpty ? 'Untitled Note' : title,
          content: plainText,
          contentJson: deltaJson,
          labelIds: _selectedLabelIds,
          isPinned: _isPinned,
          reminderId: _reminderId,
          reminderDateTime: _reminderDateTime,
          updatedAt: now,
        ) ??
        NoteModel(
          id: 'note_${now.millisecondsSinceEpoch}',
          title: title.isEmpty ? 'Untitled Note' : title,
          content: plainText,
          contentJson: deltaJson,
          labelIds: _selectedLabelIds,
          isPinned: _isPinned,
          reminderId: _reminderId,
          reminderDateTime: _reminderDateTime,
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
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          title: Text(
            'Delete Note?',
            style: AppTypography.titleMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'This action cannot be undone. Are you sure you want to delete this note and its associated reminders?',
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.crimson,
                  fontWeight: FontWeight.w700,
                ),
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

  void _openLabelSelector() {
    showDialog(
      context: context,
      builder: (_) => LabelSelectorDialog(
        notesState: widget.notesState,
        initialSelectedIds: _selectedLabelIds,
        onSelectionChanged: (updated) {
          setState(() {
            _selectedLabelIds = updated;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  void _manageReminder() {
    ReminderModel? existingReminder;
    if (_reminderId != null) {
      existingReminder = widget.notesState.reminders
          .where((r) => r.id == _reminderId)
          .firstOrNull;
    }

    final noteTitle = _titleController.text.trim().isEmpty
        ? 'Untitled Note'
        : _titleController.text.trim();

    showDialog(
      context: context,
      builder: (_) => ReminderEditorDialog(
        initialReminder: existingReminder,
        associatedNoteId: widget.initialNote?.id,
        associatedNoteTitle: noteTitle,
        onSave: (reminder) {
          if (existingReminder == null) {
            widget.notesState.addReminder(reminder);
          } else {
            widget.notesState.updateReminder(reminder);
          }
          setState(() {
            _reminderId = reminder.id;
            _reminderDateTime = reminder.dateTime;
            _hasChanges = true;
          });
        },
        onDelete: (id) {
          widget.notesState.deleteReminder(id);
          setState(() {
            _reminderId = null;
            _reminderDateTime = null;
            _hasChanges = true;
          });
        },
      ),
    );
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

    final assignedLabels = _selectedLabelIds
        .map((id) => widget.notesState.getLabelById(id))
        .whereType<dynamic>()
        .toList();

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
            // Reminder Button
            IconButton(
              icon: Icon(
                _reminderDateTime != null
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: _reminderDateTime != null
                    ? AppColors.crimson
                    : textMuted,
                size: 22,
              ),
              tooltip: _reminderDateTime != null
                  ? 'Reminder set: ${_reminderDateTime!.toString().substring(0, 16)}'
                  : 'Add reminder for this note',
              onPressed: _manageReminder,
            ),
            // Pin Toggle
            IconButton(
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _isPinned ? AppColors.crimson : textMuted,
                size: 22,
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
                icon: const Icon(Icons.delete_outline_rounded, size: 22),
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
              // Labels Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: borderColor, width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.label_outline_rounded,
                      size: 16,
                      color: textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...assignedLabels.map((l) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: LabelChipWidget(
                                  label: l,
                                  compact: true,
                                  onDelete: () {
                                    setState(() {
                                      _selectedLabelIds.remove(l.id);
                                      _hasChanges = true;
                                    });
                                  },
                                ),
                              );
                            }),
                            ActionChip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    size: 13,
                                    color: AppColors.crimson,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    assignedLabels.isEmpty
                                        ? 'Add Labels'
                                        : 'Edit Labels',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.crimson,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: surfaceColor,
                              side: BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              onPressed: _openLabelSelector,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title input
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
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

              // Formatting Toolbar
              FormattingToolbar(controller: _quillController),

              // Rich Text Editor
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: QuillEditor.basic(
                    controller: _quillController,
                    focusNode: _editorFocusNode,
                    scrollController: _editorScrollController,
                    config: QuillEditorConfig(
                      placeholder: 'Start writing your rich note...',
                      scrollable: true,
                      expands: true,
                      padding: EdgeInsets.zero,
                      autoFocus: false,
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
