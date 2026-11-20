import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/physique_state.dart';

class EditProfileScreen extends StatefulWidget {
  final PhysiqueState state;

  const EditProfileScreen({super.key, required this.state});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _descCtrl;

  late TextEditingController _waistCtrl;
  late TextEditingController _chestCtrl;
  late TextEditingController _bicepsCtrl;
  late TextEditingController _shoulderCtrl;
  late TextEditingController _forearmCtrl;
  late TextEditingController _thighCtrl;
  late TextEditingController _calfCtrl;
  late TextEditingController _neckCtrl;

  late TextEditingController _targetWeightCtrl;
  late TextEditingController _targetWaistCtrl;
  late TextEditingController _targetChestCtrl;
  late TextEditingController _targetBicepsCtrl;
  late TextEditingController _targetShoulderCtrl;
  late TextEditingController _targetThighCtrl;
  late TextEditingController _targetCalfCtrl;
  late TextEditingController _targetForearmCtrl;
  late TextEditingController _targetNeckCtrl;

  late String _sex;
  late String _fitnessGoal;

  @override
  void initState() {
    super.initState();
    final p = widget.state.profile;
    _nameCtrl = TextEditingController(text: p.name);
    _ageCtrl = TextEditingController(text: p.age.toString());
    _heightCtrl = TextEditingController(text: p.heightCm.toStringAsFixed(0));
    _weightCtrl = TextEditingController(
      text: p.currentWeightKg.toStringAsFixed(1),
    );
    _descCtrl = TextEditingController(text: p.targetPhysiqueDescription);

    _waistCtrl = TextEditingController(
      text: p.waistCm?.toStringAsFixed(1) ?? '',
    );
    _chestCtrl = TextEditingController(
      text: p.chestCm?.toStringAsFixed(1) ?? '',
    );
    _bicepsCtrl = TextEditingController(
      text: p.bicepsCm?.toStringAsFixed(1) ?? '',
    );
    _shoulderCtrl = TextEditingController(
      text: p.shoulderCm?.toStringAsFixed(1) ?? '',
    );
    _forearmCtrl = TextEditingController(
      text: p.forearmCm?.toStringAsFixed(1) ?? '',
    );
    _thighCtrl = TextEditingController(
      text: p.thighCm?.toStringAsFixed(1) ?? '',
    );
    _calfCtrl = TextEditingController(text: p.calfCm?.toStringAsFixed(1) ?? '');
    _neckCtrl = TextEditingController(text: p.neckCm?.toStringAsFixed(1) ?? '');

    _targetWeightCtrl = TextEditingController(
      text: p.targetWeightKg?.toStringAsFixed(1) ?? '',
    );
    _targetWaistCtrl = TextEditingController(
      text: p.targetWaistCm?.toStringAsFixed(1) ?? '',
    );
    _targetChestCtrl = TextEditingController(
      text: p.targetChestCm?.toStringAsFixed(1) ?? '',
    );
    _targetBicepsCtrl = TextEditingController(
      text: p.targetBicepsCm?.toStringAsFixed(1) ?? '',
    );
    _targetShoulderCtrl = TextEditingController(
      text: p.targetShoulderCm?.toStringAsFixed(1) ?? '',
    );
    _targetThighCtrl = TextEditingController(
      text: p.targetThighCm?.toStringAsFixed(1) ?? '',
    );
    _targetCalfCtrl = TextEditingController(
      text: p.targetCalfCm?.toStringAsFixed(1) ?? '',
    );
    _targetForearmCtrl = TextEditingController(
      text: p.targetForearmCm?.toStringAsFixed(1) ?? '',
    );
    _targetNeckCtrl = TextEditingController(
      text: p.targetNeckCm?.toStringAsFixed(1) ?? '',
    );

    _sex = p.sex;
    _fitnessGoal = p.fitnessGoal;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _descCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _bicepsCtrl.dispose();
    _shoulderCtrl.dispose();
    _forearmCtrl.dispose();
    _thighCtrl.dispose();
    _calfCtrl.dispose();
    _neckCtrl.dispose();
    _targetWeightCtrl.dispose();
    _targetWaistCtrl.dispose();
    _targetChestCtrl.dispose();
    _targetBicepsCtrl.dispose();
    _targetShoulderCtrl.dispose();
    _targetThighCtrl.dispose();
    _targetCalfCtrl.dispose();
    _targetForearmCtrl.dispose();
    _targetNeckCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    final updated = widget.state.profile.copyWith(
      name: name,
      age: int.tryParse(_ageCtrl.text) ?? widget.state.profile.age,
      sex: _sex,
      heightCm:
          double.tryParse(_heightCtrl.text) ?? widget.state.profile.heightCm,
      currentWeightKg:
          double.tryParse(_weightCtrl.text) ??
          widget.state.profile.currentWeightKg,
      targetPhysiqueDescription: _descCtrl.text.trim(),
      fitnessGoal: _fitnessGoal,
      waistCm: double.tryParse(_waistCtrl.text),
      chestCm: double.tryParse(_chestCtrl.text),
      bicepsCm: double.tryParse(_bicepsCtrl.text),
      shoulderCm: double.tryParse(_shoulderCtrl.text),
      forearmCm: double.tryParse(_forearmCtrl.text),
      thighCm: double.tryParse(_thighCtrl.text),
      calfCm: double.tryParse(_calfCtrl.text),
      neckCm: double.tryParse(_neckCtrl.text),
      targetWeightKg: double.tryParse(_targetWeightCtrl.text),
      targetWaistCm: double.tryParse(_targetWaistCtrl.text),
      targetChestCm: double.tryParse(_targetChestCtrl.text),
      targetBicepsCm: double.tryParse(_targetBicepsCtrl.text),
      targetShoulderCm: double.tryParse(_targetShoulderCtrl.text),
      targetThighCm: double.tryParse(_targetThighCtrl.text),
      targetCalfCm: double.tryParse(_targetCalfCtrl.text),
      targetForearmCm: double.tryParse(_targetForearmCtrl.text),
      targetNeckCm: double.tryParse(_targetNeckCtrl.text),
    );

    await widget.state.updateProfile(updated);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile & targets updated successfully!'),
        ),
      );
    }
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile & Goals'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personal Info Card
                _buildSectionHeader('PERSONAL INFORMATION', textMuted),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name *'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age (yrs)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _sex,
                              decoration: const InputDecoration(
                                labelText: 'Sex',
                              ),
                              items: ['Male', 'Female', 'Other']
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _sex = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Height (cm)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _weightCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Current Weight (kg)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fitness Goal & Target Physique Card
                _buildSectionHeader(
                  'PHYSIQUE GOALS & TARGET DESCRIPTION',
                  textMuted,
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _fitnessGoal,
                        decoration: const InputDecoration(
                          labelText: 'Primary Fitness Goal',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'muscle_gain',
                            child: Text('Muscle Gain (Hypertrophy)'),
                          ),
                          DropdownMenuItem(
                            value: 'fat_loss',
                            child: Text('Fat Loss (Cutting)'),
                          ),
                          DropdownMenuItem(
                            value: 'recomposition',
                            child: Text('Body Recomposition (Lean & Muscular)'),
                          ),
                          DropdownMenuItem(
                            value: 'general_fitness',
                            child: Text('General Strength & Fitness'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _fitnessGoal = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Target Physique Vision',
                          hintText: 'e.g. Sculpted V-taper, broad shoulders, lean 10-12% body fat',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Current Baseline Measurements
                _buildSectionHeader('CURRENT MEASUREMENTS (CM)', textMuted),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput('Waist', _waistCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput('Chest', _chestCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput('Biceps', _bicepsCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput(
                              'Shoulders',
                              _shoulderCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput('Forearms', _forearmCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput('Thighs', _thighCtrl),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput('Calves', _calfCtrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput('Neck', _neckCtrl),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ideal Target Measurements
                _buildSectionHeader('IDEAL TARGET MEASUREMENTS', textMuted),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Weight (kg)',
                              _targetWeightCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Waist (cm)',
                              _targetWaistCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Chest (cm)',
                              _targetChestCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Biceps (cm)',
                              _targetBicepsCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Shoulders (cm)',
                              _targetShoulderCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Thighs (cm)',
                              _targetThighCtrl,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Calves (cm)',
                              _targetCalfCtrl,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMeasureInput(
                              'Target Forearms (cm)',
                              _targetForearmCtrl,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Save Button
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.crimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Save Profile & Targets',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMeasureInput(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
