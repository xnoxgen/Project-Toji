import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/user_profile.dart';
import '../../state/physique_state.dart';

class OnboardingScreen extends StatefulWidget {
  final PhysiqueState state;
  final VoidCallback onFinish;

  const OnboardingScreen({
    super.key,
    required this.state,
    required this.onFinish,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  String _sex = 'Male';

  // Step 2 Controllers (Baseline)
  late TextEditingController _waistCtrl;
  late TextEditingController _chestCtrl;
  late TextEditingController _bicepsCtrl;
  late TextEditingController _shoulderCtrl;
  late TextEditingController _forearmCtrl;
  late TextEditingController _thighCtrl;
  late TextEditingController _calfCtrl;
  late TextEditingController _neckCtrl;

  // Step 3 Controllers (Goal & Ideal Targets)
  String _fitnessGoal = 'recomposition';
  late TextEditingController _descCtrl;
  late TextEditingController _targetWeightCtrl;
  late TextEditingController _targetWaistCtrl;
  late TextEditingController _targetChestCtrl;
  late TextEditingController _targetBicepsCtrl;

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
    _sex = p.sex;

    _waistCtrl = TextEditingController(
      text: p.waistCm?.toStringAsFixed(1) ?? '91.0',
    );
    _chestCtrl = TextEditingController(
      text: p.chestCm?.toStringAsFixed(1) ?? '96.0',
    );
    _bicepsCtrl = TextEditingController(
      text: p.bicepsCm?.toStringAsFixed(1) ?? '31.0',
    );
    _shoulderCtrl = TextEditingController(
      text: p.shoulderCm?.toStringAsFixed(1) ?? '46.0',
    );
    _forearmCtrl = TextEditingController(
      text: p.forearmCm?.toStringAsFixed(1) ?? '24.0',
    );
    _thighCtrl = TextEditingController(
      text: p.thighCm?.toStringAsFixed(1) ?? '47.0',
    );
    _calfCtrl = TextEditingController(
      text: p.calfCm?.toStringAsFixed(1) ?? '31.0',
    );
    _neckCtrl = TextEditingController(
      text: p.neckCm?.toStringAsFixed(1) ?? '37.0',
    );

    _fitnessGoal = p.fitnessGoal;
    _descCtrl = TextEditingController(
      text: p.targetPhysiqueDescription.isNotEmpty
          ? p.targetPhysiqueDescription
          : 'Lean, athletic, sculpted physique with broad shoulders, sharp waist, and dense muscle.',
    );
    _targetWeightCtrl = TextEditingController(
      text: p.targetWeightKg?.toStringAsFixed(1) ?? '78.0',
    );
    _targetWaistCtrl = TextEditingController(
      text: p.targetWaistCm?.toStringAsFixed(1) ?? '80.0',
    );
    _targetChestCtrl = TextEditingController(
      text: p.targetChestCm?.toStringAsFixed(1) ?? '104.0',
    );
    _targetBicepsCtrl = TextEditingController(
      text: p.targetBicepsCm?.toStringAsFixed(1) ?? '37.0',
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _bicepsCtrl.dispose();
    _shoulderCtrl.dispose();
    _forearmCtrl.dispose();
    _thighCtrl.dispose();
    _calfCtrl.dispose();
    _neckCtrl.dispose();
    _descCtrl.dispose();
    _targetWeightCtrl.dispose();
    _targetWaistCtrl.dispose();
    _targetChestCtrl.dispose();
    _targetBicepsCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter your name')));
        return;
      }
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final newProfile = UserProfile(
      name: _nameCtrl.text.trim().isNotEmpty
          ? _nameCtrl.text.trim()
          : 'Athlete',
      age: int.tryParse(_ageCtrl.text) ?? 20,
      sex: _sex,
      heightCm: double.tryParse(_heightCtrl.text) ?? 175.0,
      currentWeightKg: double.tryParse(_weightCtrl.text) ?? 75.0,
      waistCm: double.tryParse(_waistCtrl.text),
      chestCm: double.tryParse(_chestCtrl.text),
      bicepsCm: double.tryParse(_bicepsCtrl.text),
      shoulderCm: double.tryParse(_shoulderCtrl.text),
      forearmCm: double.tryParse(_forearmCtrl.text),
      thighCm: double.tryParse(_thighCtrl.text),
      calfCm: double.tryParse(_calfCtrl.text),
      neckCm: double.tryParse(_neckCtrl.text),
      fitnessGoal: _fitnessGoal,
      targetPhysiqueDescription: _descCtrl.text.trim(),
      targetWeightKg: double.tryParse(_targetWeightCtrl.text),
      targetWaistCm: double.tryParse(_targetWaistCtrl.text),
      targetChestCm: double.tryParse(_targetChestCtrl.text),
      targetBicepsCm: double.tryParse(_targetBicepsCtrl.text),
    );

    await widget.state.completeOnboarding(newProfile);
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textMuted = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              children: [
                // Top Progress Indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                'PHYSIQUE SETUP',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.crimson,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Step ${_currentStep + 1} of 3',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [0, 1, 2].map((i) {
                          final isActive = i <= _currentStep;
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                              height: 3,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.crimson
                                    : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentStep = idx),
                    children: [
                      _buildStep1(
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                      _buildStep2(
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                      _buildStep3(
                        surfaceColor,
                        borderColor,
                        textColor,
                        textMuted,
                      ),
                    ],
                  ),
                ),

                // Bottom Navigation Controls
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: _prevPage,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                          child: const Text('Back'),
                        )
                      else if (_currentStep == 1)
                        TextButton(
                          onPressed: _nextPage,
                          child: const Text('Skip Optional'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.crimson,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          _currentStep == 2 ? 'Launch PHYSIQUE' : 'Continue',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Step 1: Athlete Info
  Widget _buildStep1(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to PHYSIQUE',
            style: AppTypography.displayMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Build progressive overload routines, monitor precise body dimensions, and sculpt your ideal build.',
            style: AppTypography.bodyLarge.copyWith(color: textMuted),
          ),
          const SizedBox(height: 28),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Your Name *',
                    hintText: 'e.g., Kavya',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ageCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age (years)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sex,
                        decoration: const InputDecoration(labelText: 'Sex'),
                        items: ['Male', 'Female', 'Other']
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _sex = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Current Weight',
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: Starting Measurements
  Widget _buildStep2(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Starting Baseline',
                style: AppTypography.displayMedium.copyWith(color: textColor),
              ),
              TextButton(
                onPressed: _nextPage,
                child: const Text('Skip for now'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Record your starting circumference measurements. These can be adjusted anytime.',
            style: AppTypography.bodyLarge.copyWith(color: textMuted),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField('Waist (cm)', _waistCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureField('Chest (cm)', _chestCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField('Biceps (cm)', _bicepsCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureField(
                        'Shoulders (cm)',
                        _shoulderCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField('Forearms (cm)', _forearmCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureField('Thighs (cm)', _thighCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField('Calves (cm)', _calfCtrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMeasureField('Neck (cm)', _neckCtrl)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Goal & Target Physique
  Widget _buildStep3(
    Color surfaceColor,
    Color borderColor,
    Color textColor,
    Color textMuted,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Physique',
            style: AppTypography.displayMedium.copyWith(color: textColor),
          ),
          const SizedBox(height: 6),
          Text(
            'Define your desired outcome to calibrate progress charts and target milestones.',
            style: AppTypography.bodyLarge.copyWith(color: textMuted),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text('General Strength & Conditioning'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _fitnessGoal = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Target Physique Vision',
                    hintText: 'e.g. Athletic V-taper, sculpted delts and back, sub-12% body fat',
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'IDEAL TARGET MEASUREMENTS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.crimson,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField(
                        'Target Weight (kg)',
                        _targetWeightCtrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureField(
                        'Target Waist (cm)',
                        _targetWaistCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMeasureField(
                        'Target Chest (cm)',
                        _targetChestCtrl,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMeasureField(
                        'Target Biceps (cm)',
                        _targetBicepsCtrl,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasureField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}
