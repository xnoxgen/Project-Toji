import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_chart.dart';
import '../../state/physique_state.dart';
import 'add_measurement_dialog.dart';

class ProgressScreen extends StatefulWidget {
  final PhysiqueState state;

  const ProgressScreen({super.key, required this.state});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedMetric = 'weight';
  String _selectedPeriod = '30d';
  String _selectedStrengthExercise = 'Bench Press';

  final Map<String, String> _metrics = {
    'weight': 'Weight',
    'waist': 'Waist',
    'chest': 'Chest',
    'biceps': 'Biceps',
    'shoulders': 'Shoulders',
    'forearms': 'Forearms',
    'thighs': 'Thighs',
    'calves': 'Calves',
    'neck': 'Neck',
    'strength': 'Strength',
  };

  final List<String> _periods = ['7d', '30d', '3m', '6m', '1y'];

  void _openAddMeasurementDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddMeasurementDialog(
        state: widget.state,
        initialMetric: _selectedMetric == 'strength' ? 'weight' : _selectedMetric,
      ),
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

    final isStrengthMode = _selectedMetric == 'strength';
    final unit = isStrengthMode ? 'kg' : (_selectedMetric == 'weight' ? 'kg' : 'cm');

    // Prepare chart data
    List<ChartDataPoint> chartPoints = [];
    double? targetValue;
    double? currentVal;
    double? prevVal;
    double? delta;

    if (isStrengthMode) {
      final records = widget.state.getExerciseStrengthProgression(_selectedStrengthExercise, period: _selectedPeriod);
      chartPoints = records.map((r) {
        return ChartDataPoint(
          date: r['date'] as DateTime,
          value: r['weight'] as double,
        );
      }).toList();
      if (chartPoints.isNotEmpty) {
        currentVal = chartPoints.last.value;
        if (chartPoints.length > 1) {
          prevVal = chartPoints[chartPoints.length - 2].value;
          delta = currentVal - chartPoints.first.value;
        }
      }
    } else {
      final records = widget.state.getMeasurementsForMetric(_selectedMetric, period: _selectedPeriod);
      chartPoints = records.map((m) {
        return ChartDataPoint(
          date: m.date,
          value: m.value,
        );
      }).toList();

      currentVal = widget.state.getLatestMeasurement(_selectedMetric);
      prevVal = widget.state.getPreviousMeasurement(_selectedMetric);
      delta = widget.state.getMeasurementDelta(_selectedMetric);
      targetValue = widget.state.getTargetForMetric(_selectedMetric);
    }

    // Historical records for table
    final allHistorical = isStrengthMode
        ? []
        : widget.state.measurements
            .where((m) => m.metricType == _selectedMetric)
            .toList()
            .reversed
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.crimson),
            tooltip: 'Log Measurement',
            onPressed: _openAddMeasurementDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddMeasurementDialog,
        backgroundColor: AppColors.crimson,
        foregroundColor: Colors.white,
        tooltip: 'Log Measurement',
        child: const Icon(Icons.add_rounded),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Metric Category Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _metrics.length,
                    separatorBuilder: (ctx, i) => const SizedBox(width: 6),
                    itemBuilder: (ctx, i) {
                      final key = _metrics.keys.elementAt(i);
                      final label = _metrics[key]!;
                      final isSelected = _selectedMetric == key;

                      return InkWell(
                        onTap: () => setState(() => _selectedMetric = key),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                            label,
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? Colors.white : textColor,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Strength Exercise Selector (if Strength Mode selected)
                if (isStrengthMode) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedStrengthExercise,
                        isExpanded: true,
                        dropdownColor: surfaceColor,
                        items: [
                          'Bench Press',
                          'Barbell Squat',
                          'Romanian Deadlift',
                          'Lat Pulldown',
                          'Incline Dumbbell Press',
                          'Pull-ups',
                          'Hack Squat',
                          'Lateral Raises',
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStrengthExercise = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Period Filter Selector (7d, 30d, 3m, 6m, 1y)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _periods.map((p) {
                    final isSel = _selectedPeriod == p;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedPeriod = p),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.crimson : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSel ? AppColors.crimson : borderColor,
                            ),
                          ),
                          child: Text(
                            p.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: isSel ? Colors.white : textMuted,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Primary Metric Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isStrengthMode
                                    ? _selectedStrengthExercise.toUpperCase()
                                    : '${_metrics[_selectedMetric]!.toUpperCase()} OVERVIEW',
                                style: AppTypography.labelSmall.copyWith(
                                  color: textMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    currentVal != null ? currentVal.toStringAsFixed(1) : '--',
                                    style: AppTypography.metricLarge.copyWith(
                                      color: textColor,
                                      fontSize: 34,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    unit,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Delta change
                          if (delta != null) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      delta > 0
                                          ? Icons.arrow_upward_rounded
                                          : (delta < 0
                                              ? Icons.arrow_downward_rounded
                                              : Icons.remove_rounded),
                                      size: 16,
                                      color: delta > 0 ? AppColors.crimson : AppColors.success,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${delta > 0 ? "+" : ""}${delta.toStringAsFixed(1)} $unit',
                                      style: AppTypography.titleMedium.copyWith(
                                        color: delta > 0 ? AppColors.crimson : AppColors.success,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Overall Change',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Target and previous info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prevVal != null
                                ? 'Previous: ${prevVal.toStringAsFixed(1)} $unit'
                                : 'Initial baseline recorded',
                            style: AppTypography.bodyMedium.copyWith(color: textMuted, fontSize: 12),
                          ),
                          if (targetValue != null) ...[
                            Text(
                              'Target: ${targetValue.toStringAsFixed(1)} $unit',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.crimson,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Chart Card
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TREND CHART',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Drag to inspect dates',
                            style: AppTypography.labelSmall.copyWith(
                              color: textMuted.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      CustomChart(
                        dataPoints: chartPoints,
                        targetValue: targetValue,
                        unit: unit,
                        height: 220,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Historical Log Records
                if (!isStrengthMode) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HISTORICAL LOGS',
                        style: AppTypography.labelSmall.copyWith(
                          color: textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '${allHistorical.length} entries',
                        style: AppTypography.labelSmall.copyWith(color: textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  allHistorical.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Center(
                            child: Text(
                              'No entries logged yet.',
                              style: TextStyle(color: textMuted),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allHistorical.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 1),
                            itemBuilder: (ctx, i) {
                              final item = allHistorical[i];
                              final dateStr = DateFormat('MMM d, yyyy').format(item.date);
                              return ListTile(
                                dense: true,
                                title: Text(
                                  '${item.value.toStringAsFixed(1)} ${item.unit}',
                                  style: AppTypography.titleMedium.copyWith(
                                    color: textColor,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: item.notes != null && item.notes!.isNotEmpty
                                    ? Text(
                                        item.notes!,
                                        style: TextStyle(color: textMuted, fontSize: 11),
                                      )
                                    : null,
                                trailing: Text(
                                  dateStr,
                                  style: AppTypography.labelSmall.copyWith(color: textMuted),
                                ),
                              );
                            },
                          ),
                        ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
