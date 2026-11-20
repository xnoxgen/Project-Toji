import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/note_model.dart';
import '../../data/models/reminder_model.dart';
import '../../state/notes_state.dart';
import '../../state/physique_state.dart';
import 'note_editor_screen.dart';
import 'reminder_editor_dialog.dart';
import 'widgets/category_filter_chips.dart';
import 'widgets/note_card.dart';
import 'widgets/reminder_card.dart';

class NotesScreen extends StatefulWidget {
  final NotesState notesState;
  final PhysiqueState physiqueState;

  const NotesScreen({
    super.key,
    required this.notesState,
    required this.physiqueState,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showCompletedReminders = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      widget.notesState.setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteEditor([NoteModel? note]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          initialNote: note,
          onSave: (savedNote) {
            if (note == null) {
              widget.notesState.addNote(savedNote);
            } else {
              widget.notesState.updateNote(savedNote);
            }
          },
          onDelete: (id) => widget.notesState.deleteNote(id),
        ),
      ),
    );
  }

  void _openReminderDialog([ReminderModel? reminder]) {
    showDialog(
      context: context,
      builder: (_) => ReminderEditorDialog(
        initialReminder: reminder,
        onSave: (saved) {
          if (reminder == null) {
            widget.notesState.addReminder(saved);
          } else {
            widget.notesState.updateReminder(saved);
          }
        },
        onDelete: (id) => widget.notesState.deleteReminder(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ListenableBuilder(
      listenable: widget.notesState,
      builder: (context, _) {
        final currentTab = widget.notesState.activeModuleTab;

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.crimson,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'NOTES & REMINDERS',
                                style: AppTypography.labelSmall.copyWith(
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.crimson,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentTab == 0 ? 'Personal Notes' : 'Smart Reminders',
                            style: AppTypography.displayMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Theme Indicator / Module badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              currentTab == 0 ? Icons.note_alt_rounded : Icons.alarm_rounded,
                              size: 14,
                              color: AppColors.crimson,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentTab == 0
                                  ? '${widget.notesState.notes.length} notes'
                                  : '${widget.notesState.reminders.length} items',
                              style: AppTypography.labelSmall.copyWith(
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Segmented Tab Switch: Notes vs Reminders
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.notesState.setActiveModuleTab(0),
                            borderRadius: BorderRadius.circular(9),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: currentTab == 0 ? AppColors.crimson : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: 18,
                                    color: currentTab == 0 ? Colors.white : textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Notes (${widget.notesState.notes.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: currentTab == 0 ? Colors.white : textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => widget.notesState.setActiveModuleTab(1),
                            borderRadius: BorderRadius.circular(9),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: currentTab == 1 ? AppColors.crimson : Colors.transparent,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    size: 18,
                                    color: currentTab == 1 ? Colors.white : textMuted,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Reminders (${widget.notesState.reminders.length})',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: currentTab == 1 ? Colors.white : textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: textMuted),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                color: textMuted,
                                onPressed: () {
                                  _searchController.clear();
                                  widget.notesState.setSearchQuery('');
                                },
                              )
                            : null,
                        hintText: currentTab == 0
                            ? 'Search note title or content...'
                            : 'Search reminders...',
                        hintStyle: TextStyle(color: textMuted.withAlpha(150), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                ),

                // Content View (Notes or Reminders)
                Expanded(
                  child: currentTab == 0 ? _buildNotesView() : _buildRemindersView(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.crimson,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: Icon(currentTab == 0 ? Icons.add_rounded : Icons.alarm_add_rounded),
            label: Text(
              currentTab == 0 ? 'New Note' : 'Add Reminder',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              if (currentTab == 0) {
                _openNoteEditor();
              } else {
                _openReminderDialog();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildNotesView() {
    final pinned = widget.notesState.pinnedNotes;
    final unpinned = widget.notesState.unpinnedNotes;
    final totalCount = widget.notesState.filteredNotes.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      children: [
        // Category Chips
        CategoryFilterChips(
          selectedCategory: widget.notesState.selectedCategory,
          onSelectCategory: (cat) => widget.notesState.setSelectedCategory(cat),
        ),
        const SizedBox(height: 10),

        Expanded(
          child: totalCount == 0
              ? _buildEmptyState(
                  icon: Icons.note_alt_outlined,
                  title: 'No notes found',
                  subtitle: widget.notesState.searchQuery.isNotEmpty ||
                          widget.notesState.selectedCategory != null
                      ? 'Try adjusting your search query or category filter.'
                      : 'Capture your thoughts, workouts, nutrition plans and ideas.',
                  actionText: 'Create Your First Note',
                  onAction: () => _openNoteEditor(),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                  children: [
                    // Pinned Notes Section
                    if (pinned.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.crimson),
                            const SizedBox(width: 6),
                            Text(
                              'PINNED NOTES',
                              style: AppTypography.labelSmall.copyWith(
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                                color: textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...pinned.map((n) => NoteCard(
                            key: ValueKey(n.id),
                            note: n,
                            onTap: () => _openNoteEditor(n),
                            onTogglePin: () => widget.notesState.togglePinNote(n.id),
                          )),
                      const SizedBox(height: 14),
                    ],

                    // Other Notes Section
                    if (unpinned.isNotEmpty) ...[
                      if (pinned.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'RECENT NOTES',
                            style: AppTypography.labelSmall.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w700,
                              color: textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ...unpinned.map((n) => NoteCard(
                            key: ValueKey(n.id),
                            note: n,
                            onTap: () => _openNoteEditor(n),
                            onTogglePin: () => widget.notesState.togglePinNote(n.id),
                          )),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildRemindersView() {
    final overdue = widget.notesState.overdueReminders;
    final upcoming = widget.notesState.upcomingReminders;
    final completed = widget.notesState.completedReminders;
    final totalCount = widget.notesState.filteredReminders.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (totalCount == 0) {
      return _buildEmptyState(
        icon: Icons.alarm_outlined,
        title: 'No reminders set',
        subtitle: widget.notesState.searchQuery.isNotEmpty
            ? 'No reminders match your search.'
            : 'Schedule pre-workout fuel, supplements, or mobility sessions.',
        actionText: 'Set a Reminder',
        onAction: () => _openReminderDialog(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
      children: [
        // Overdue Section
        if (overdue.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.crimson),
                const SizedBox(width: 6),
                Text(
                  'OVERDUE (${overdue.length})',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                    color: AppColors.crimson,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ...overdue.map((r) => ReminderCard(
                key: ValueKey(r.id),
                reminder: r,
                onToggleComplete: () => widget.notesState.toggleCompleteReminder(r.id),
                onEdit: () => _openReminderDialog(r),
                onDelete: () => widget.notesState.deleteReminder(r.id),
              )),
          const SizedBox(height: 14),
        ],

        // Upcoming Section
        if (upcoming.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 4),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.crimson),
                const SizedBox(width: 6),
                Text(
                  'UPCOMING (${upcoming.length})',
                  style: AppTypography.labelSmall.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ...upcoming.map((r) => ReminderCard(
                key: ValueKey(r.id),
                reminder: r,
                onToggleComplete: () => widget.notesState.toggleCompleteReminder(r.id),
                onEdit: () => _openReminderDialog(r),
                onDelete: () => widget.notesState.deleteReminder(r.id),
              )),
          const SizedBox(height: 14),
        ],

        // Completed Section
        if (completed.isNotEmpty) ...[
          InkWell(
            onTap: () {
              setState(() {
                _showCompletedReminders = !_showCompletedReminders;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _showCompletedReminders
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 18,
                    color: textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'COMPLETED (${completed.length})',
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showCompletedReminders) ...[
            const SizedBox(height: 4),
            ...completed.map((r) => ReminderCard(
                  key: ValueKey(r.id),
                  reminder: r,
                  onToggleComplete: () => widget.notesState.toggleCompleteReminder(r.id),
                  onEdit: () => _openReminderDialog(r),
                  onDelete: () => widget.notesState.deleteReminder(r.id),
                )),
          ],
        ],
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
              ),
              child: Icon(icon, size: 40, color: textMuted),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimson,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
