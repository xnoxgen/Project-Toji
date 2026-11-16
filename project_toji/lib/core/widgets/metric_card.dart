import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final double? delta;
  final String? targetText;
  final IconData? icon;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    this.delta,
    this.targetText,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  if (icon != null)
                    Icon(icon, size: 16, color: AppColors.crimson),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.metricLarge.copyWith(
                      color: textColor,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (delta != null) ...[
                    Row(
                      children: [
                        Icon(
                          delta! > 0
                              ? Icons.arrow_upward_rounded
                              : (delta! < 0
                                  ? Icons.arrow_downward_rounded
                                  : Icons.remove_rounded),
                          size: 13,
                          color: delta! > 0
                              ? AppColors.crimson
                              : (delta! < 0 ? AppColors.success : textMuted),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${delta! > 0 ? "+" : ""}${delta!.toStringAsFixed(1)} $unit',
                          style: AppTypography.labelSmall.copyWith(
                            color: delta! > 0
                                ? AppColors.crimson
                                : (delta! < 0 ? AppColors.success : textMuted),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Baseline',
                      style: AppTypography.labelSmall.copyWith(color: textMuted),
                    ),
                  ],
                  if (targetText != null)
                    Flexible(
                      child: Text(
                        targetText!,
                        style: AppTypography.labelSmall.copyWith(
                          color: textMuted,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

