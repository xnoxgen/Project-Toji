import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CrimsonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isOutlined;
  final bool isFullWidth;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  const CrimsonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isOutlined = false,
    this.isFullWidth = true,
    this.isLoading = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          );

    final btnPadding = padding ??
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14);

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            side: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
            padding: btnPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: content,
        ),
      );
    }

    if (isSecondary) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            foregroundColor:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            elevation: 0,
            padding: btnPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.crimson.withValues(alpha: 0.4),
          elevation: 0,
          padding: btnPadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: content,
      ),
    );
  }
}

