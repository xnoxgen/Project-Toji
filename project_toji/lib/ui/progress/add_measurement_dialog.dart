import 'package:flutter/material.dart';

import '../../state/physique_state.dart';

class AddMeasurementDialog extends StatefulWidget {
  final PhysiqueState state;
  final String initialMetric;

  const AddMeasurementDialog({
    super.key,
    required this.state,
    this.initialMetric = 'weight',
  });

  @override
  State<AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<AddMeasurementDialog> {
  late String _selectedMetric;
  late TextEditingController _valController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();

  final Map<String, String> _metricNames = {
    'weight': 'Body Weight (kg)',
    'waist': 'Waist (cm)',
    'chest': 'Chest (cm)',
    'biceps': 'Biceps (cm)',
    'shoulders': 'Shoulders (cm)',
    'forearms': 'Forearms (cm)',
    'thighs': 'Thighs (cm)',
    'calves': 'Calves (cm)',
    'neck': 'Neck (cm)',
  };

  @override
  void initState() {
    super.initState();
    _selectedMetric = widget.initialMetric;
    final latestVal = widget.state.getLatestMeasurement(_selectedMetric);
    _valController = TextEditingController(
      text: latestVal != null ? latestVal.toStringAsFixed(1) : '',
    );
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _valController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onMetricChanged(String? val) {
    if (val != null) {
      setState(() {
        _selectedMetric = val;
        final latest = widget.state.getLatestMeasurement(val);
        _valController.text = latest != null ? latest.toStringAsFixed(1) : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = _selectedMetric == 'weight' ? 'kg' : 'cm';

    return AlertDialog(
      title: const Text('Log Body Measurement'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedMetric,
              decoration: const InputDecoration(
                labelText: 'Measurement Metric',
              ),
              items: _metricNames.entries.map((e) {
                return DropdownMenuItem(value: e.key, child: Text(e.value));
              }).toList(),
              onChanged: _onMetricChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: 'Value', suffixText: unit),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today_outlined, size: 18),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. Measured empty stomach in morning',
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
          onPressed: () async {
            final val = double.tryParse(_valController.text.trim());
            if (val == null || val <= 0) return;
            final nav = Navigator.of(context);
            await widget.state.addMeasurement(
              _selectedMetric,
              val,
              date: _selectedDate,
              notes: _notesController.text.trim(),
            );
            if (mounted) nav.pop(true);
          },
          child: const Text('Save Entry'),
        ),
      ],
    );
  }
}
