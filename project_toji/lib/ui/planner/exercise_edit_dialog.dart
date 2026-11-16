import 'package:flutter/material.dart';
import '../../data/models/workout_plan.dart';

class ExerciseEditDialog extends StatefulWidget {
  final PlannedExercise exercise;

  const ExerciseEditDialog({super.key, required this.exercise});

  @override
  State<ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<ExerciseEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _setsController = TextEditingController(text: widget.exercise.targetSets.toString());
    _repsController = TextEditingController(text: widget.exercise.targetReps);
    _restController = TextEditingController(text: widget.exercise.restSeconds.toString());
    _notesController = TextEditingController(text: widget.exercise.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Exercise Target'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target Sets'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(labelText: 'Target Reps'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _restController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rest Between Sets (sec)',
                suffixText: 'sec',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Instructions / Personal Notes',
                hintText: 'e.g., Strict pause at bottom, RIR 1-2',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;

            final updated = widget.exercise.copyWith(
              name: name,
              targetSets: int.tryParse(_setsController.text) ?? widget.exercise.targetSets,
              targetReps: _repsController.text.trim().isNotEmpty
                  ? _repsController.text.trim()
                  : widget.exercise.targetReps,
              restSeconds: int.tryParse(_restController.text) ?? widget.exercise.restSeconds,
              notes: _notesController.text.trim(),
            );
            Navigator.of(context).pop(updated);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
