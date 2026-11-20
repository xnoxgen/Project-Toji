import 'package:flutter/material.dart';

import '../../../data/models/label_model.dart';

class LabelChipWidget extends StatelessWidget {
  final LabelModel label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool compact;

  const LabelChipWidget({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(label.colorValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 3 : 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(50) : color.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : color.withAlpha(80),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 6 : 8,
                height: compact ? 6 : 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label.name,
                style: TextStyle(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: compact ? 11 : 12,
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close_rounded,
                    size: compact ? 12 : 14,
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
