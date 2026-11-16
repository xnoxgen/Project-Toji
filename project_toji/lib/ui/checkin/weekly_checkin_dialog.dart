import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/weekly_checkin.dart';
import '../../state/physique_state.dart';

class WeeklyCheckinDialog extends StatefulWidget {
  final PhysiqueState state;

  const WeeklyCheckinDialog({super.key, required this.state});

  @override
  State<WeeklyCheckinDialog> createState() => _WeeklyCheckinDialogState();
}

class _WeeklyCheckinDialogState extends State<WeeklyCheckinDialog> {
  late TextEditingController _weightCtrl;
  late TextEditingController _waistCtrl;
  late TextEditingController _chestCtrl;
  late TextEditingController _bicepsCtrl;
  late TextEditingController _thighsCtrl;
  late TextEditingController _forearmsCtrl;
  late TextEditingController _calvesCtrl;
  late TextEditingController _neckCtrl;
  late TextEditingController _notesCtrl;

  int _consistencyRating = 4;
  int _recoveryRating = 4;

  @override
  void initState() {
    super.initState();
    final p = widget.state.profile;
    _weightCtrl = TextEditingController(text: p.currentWeightKg.toStringAsFixed(1));
    _waistCtrl = TextEditingController(text: p.waistCm?.toStringAsFixed(1) ?? '');
    _chestCtrl = TextEditingController(text: p.chestCm?.toStringAsFixed(1) ?? '');
    _bicepsCtrl = TextEditingController(text: p.bicepsCm?.toStringAsFixed(1) ?? '');
    _thighsCtrl = TextEditingController(text: p.thighCm?.toStringAsFixed(1) ?? '');
    _forearmsCtrl = TextEditingController(text: p.forearmCm?.toStringAsFixed(1) ?? '');
    _calvesCtrl = TextEditingController(text: p.calfCm?.toStringAsFixed(1) ?? '');
    _neckCtrl = TextEditingController(text: p.neckCm?.toStringAsFixed(1) ?? '');
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _bicepsCtrl.dispose();
    _thighsCtrl.dispose();
    _forearmsCtrl.dispose();
    _calvesCtrl.dispose();
    _neckCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCheckin() async {
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid body weight')),
      );
      return;
    }

    final checkin = WeeklyCheckIn(
      id: 'checkin_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      weightKg: weight,
      waistCm: double.tryParse(_waistCtrl.text.trim()),
      chestCm: double.tryParse(_chestCtrl.text.trim()),
      bicepsCm: double.tryParse(_bicepsCtrl.text.trim()),
      thighsCm: double.tryParse(_thighsCtrl.text.trim()),
      forearmsCm: double.tryParse(_forearmsCtrl.text.trim()),
      calvesCm: double.tryParse(_calvesCtrl.text.trim()),
      neckCm: double.tryParse(_neckCtrl.text.trim()),
      workoutConsistencyRating: _consistencyRating,
      energyRecoveryRating: _recoveryRating,
      notes: _notesCtrl.text.trim(),
    );

    await widget.state.submitWeeklyCheckIn(checkin);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final elevatedColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final prevWeight = widget.state.getLatestMeasurement('weight');
    final prevWaist = widget.state.getLatestMeasurement('waist');
    final prevChest = widget.state.getLatestMeasurement('chest');
    final prevBiceps = widget.state.getLatestMeasurement('biceps');

    return Dialog(
      backgroundColor: surfaceColor,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assessment_outlined, size: 18, color: AppColors.crimson),
                            const SizedBox(width: 6),
                            Text(
                              'WEEKLY REVIEW & CHECK-IN',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.crimson,
                                letterSpacing: 1.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update Physique Measurements',
                          style: AppTypography.titleLarge.copyWith(color: textColor, fontSize: 18),
                        ),
                        Text(
                          'Log your latest numbers to calibrate progress trends.',
                          style: AppTypography.bodyMedium.copyWith(color: textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: textMuted,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Metric Inputs
                    _buildFieldRow('Body Weight (kg) *', _weightCtrl, prevWeight, 'kg'),
                    const SizedBox(height: 12),
                    _buildFieldRow('Waist Circumference (cm)', _waistCtrl, prevWaist, 'cm'),
                    const SizedBox(height: 12),
                    _buildFieldRow('Chest Circumference (cm)', _chestCtrl, prevChest, 'cm'),
                    const SizedBox(height: 12),
                    _buildFieldRow('Biceps Circumference (cm)', _bicepsCtrl, prevBiceps, 'cm'),
                    const SizedBox(height: 16),

                    // Collapsible Optional Measurements
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        'Additional Body Measurements (Optional)',
                        style: AppTypography.titleMedium.copyWith(
                          fontSize: 13,
                          color: AppColors.crimson,
                        ),
                      ),
                      children: [
                        const SizedBox(height: 8),
                        _buildFieldRow('Thighs (cm)', _thighsCtrl, widget.state.profile.thighCm, 'cm'),
                        const SizedBox(height: 10),
                        _buildFieldRow('Forearms (cm)', _forearmsCtrl, widget.state.profile.forearmCm, 'cm'),
                        const SizedBox(height: 10),
                        _buildFieldRow('Calves (cm)', _calvesCtrl, widget.state.profile.calfCm, 'cm'),
                        const SizedBox(height: 10),
                        _buildFieldRow('Neck (cm)', _neckCtrl, widget.state.profile.neckCm, 'cm'),
                        const SizedBox(height: 10),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Weekly Workout Consistency Rating
                    Text(
                      'WORKOUT CONSISTENCY (1-5)',
                      style: AppTypography.labelSmall.copyWith(color: textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 3, 4, 5].map((val) {
                        final isSel = _consistencyRating == val;
                        return InkWell(
                          onTap: () => setState(() => _consistencyRating = val),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.crimson : elevatedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppColors.crimson : borderColor),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$val',
                              style: TextStyle(
                                color: isSel ? Colors.white : textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Energy & Recovery Rating
                    Text(
                      'ENERGY & RECOVERY (1-5)',
                      style: AppTypography.labelSmall.copyWith(color: textMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [1, 2, 3, 4, 5].map((val) {
                        final isSel = _recoveryRating == val;
                        return InkWell(
                          onTap: () => setState(() => _recoveryRating = val),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.crimson : elevatedColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSel ? AppColors.crimson : borderColor),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$val',
                              style: TextStyle(
                                color: isSel ? Colors.white : textColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Check-in Notes
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Weekly Reflection / Notes',
                        hintText: 'e.g., Felt strong on bench press, energy high, slept well.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      await widget.state.dismissCheckInForDays(3);
                      if (mounted) nav.pop();
                    },
                    child: Text('Remind in 3 Days', style: TextStyle(color: textMuted, fontSize: 13)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _submitCheckin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crimson,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Check-In'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(
    String label,
    TextEditingController controller,
    double? previousValue,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            if (previousValue != null)
              Text(
                'Previous: ${previousValue.toStringAsFixed(1)} $unit',
                style: AppTypography.labelSmall.copyWith(color: AppColors.crimson, fontSize: 11),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: unit,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
      ],
    );
  }
}
