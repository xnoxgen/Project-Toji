import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ChartDataPoint {
  final DateTime date;
  final double value;
  final String? label;

  const ChartDataPoint({
    required this.date,
    required this.value,
    this.label,
  });
}

class CustomChart extends StatefulWidget {
  final List<ChartDataPoint> dataPoints;
  final double? targetValue;
  final String unit;
  final double height;
  final bool showDots;
  final bool isBarChart;

  const CustomChart({
    super.key,
    required this.dataPoints,
    this.targetValue,
    this.unit = '',
    this.height = 200,
    this.showDots = true,
    this.isBarChart = false,
  });

  @override
  State<CustomChart> createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.dataPoints.isEmpty) {
      return Container(
        height: widget.height,
        alignment: Alignment.center,
        child: Text(
          'No historical records in this period',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanDown: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
          onPanUpdate: (details) => _handleTouch(details.localPosition, constraints.maxWidth),
          onTapUp: (_) => setState(() => _selectedIndex = null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tooltip if selected
              if (_selectedIndex != null && _selectedIndex! < widget.dataPoints.length) ...[
                _buildTooltip(widget.dataPoints[_selectedIndex!], isDark),
              ] else ...[
                const SizedBox(height: 24),
              ],
              SizedBox(
                height: widget.height - 24,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, widget.height - 24),
                  painter: _ChartPainter(
                    dataPoints: widget.dataPoints,
                    targetValue: widget.targetValue,
                    selectedIndex: _selectedIndex,
                    isDark: isDark,
                    unit: widget.unit,
                    showDots: widget.showDots,
                    isBarChart: widget.isBarChart,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleTouch(Offset localPosition, double width) {
    if (widget.dataPoints.isEmpty) return;
    final paddingH = 30.0;
    final chartWidth = width - (paddingH * 2);
    if (chartWidth <= 0) return;

    final x = (localPosition.dx - paddingH).clamp(0.0, chartWidth);
    final count = widget.dataPoints.length;
    final index = ((x / chartWidth) * (count - 1)).round().clamp(0, count - 1);
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTooltip(ChartDataPoint point, bool isDark) {
    final dateStr = DateFormat('MMM d, yyyy').format(point.date);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$dateStr : ',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${point.value.toStringAsFixed(1)} ${widget.unit}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.crimson,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<ChartDataPoint> dataPoints;
  final double? targetValue;
  final int? selectedIndex;
  final bool isDark;
  final String unit;
  final bool showDots;
  final bool isBarChart;

  _ChartPainter({
    required this.dataPoints,
    this.targetValue,
    this.selectedIndex,
    required this.isDark,
    required this.unit,
    required this.showDots,
    required this.isBarChart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paddingL = 36.0;
    final paddingR = 16.0;
    final paddingT = 16.0;
    final paddingB = 26.0;

    final plotWidth = size.width - paddingL - paddingR;
    final plotHeight = size.height - paddingT - paddingB;

    if (plotWidth <= 0 || plotHeight <= 0) return;

    // Calculate Y bounds
    double minY = dataPoints.map((p) => p.value).reduce(math.min);
    double maxY = dataPoints.map((p) => p.value).reduce(math.max);

    if (targetValue != null) {
      minY = math.min(minY, targetValue!);
      maxY = math.max(maxY, targetValue!);
    }

    if (minY == maxY) {
      minY -= 5.0;
      maxY += 5.0;
    } else {
      final yPadding = (maxY - minY) * 0.15;
      minY -= yPadding;
      maxY += yPadding;
    }

    // Grid lines & Y axis labels
    final gridPaint = Paint()
      ..color = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle
      ..strokeWidth = 1;

    final textStyle = AppTypography.labelSmall.copyWith(
      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
      fontSize: 10,
    );

    const gridLines = 3;
    for (int i = 0; i <= gridLines; i++) {
      final ratio = i / gridLines;
      final y = paddingT + (plotHeight * (1 - ratio));
      final val = minY + ((maxY - minY) * ratio);

      canvas.drawLine(
        Offset(paddingL, y),
        Offset(size.width - paddingR, y),
        gridPaint,
      );

      final textSpan = TextSpan(text: val.toStringAsFixed(0), style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(paddingL - textPainter.width - 6, y - (textPainter.height / 2)),
      );
    }

    // Target Value Dashed Line
    if (targetValue != null) {
      final targetY = paddingT +
          plotHeight * (1 - ((targetValue! - minY) / (maxY - minY)));
      final targetPaint = Paint()
        ..color = AppColors.crimson.withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      _drawDashedLine(
        canvas,
        Offset(paddingL, targetY),
        Offset(size.width - paddingR, targetY),
        targetPaint,
      );

      final targetSpan = TextSpan(
        text: 'Target ${targetValue!.toStringAsFixed(1)}',
        style: textStyle.copyWith(
          color: AppColors.crimson,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
      final tp = TextPainter(
        text: targetSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - paddingR - tp.width, targetY - tp.height - 2));
    }

    if (dataPoints.length == 1) {
      // Single data point: draw centered dot
      final cx = paddingL + (plotWidth / 2);
      final cy = paddingT + (plotHeight / 2);
      final dotPaint = Paint()..color = AppColors.crimson;
      canvas.drawCircle(Offset(cx, cy), 5, dotPaint);
      return;
    }

    final points = <Offset>[];
    for (int i = 0; i < dataPoints.length; i++) {
      final x = paddingL + (plotWidth * (i / (dataPoints.length - 1)));
      final y = paddingT +
          plotHeight * (1 - ((dataPoints[i].value - minY) / (maxY - minY)));
      points.add(Offset(x, y));
    }

    if (isBarChart) {
      // Draw Bars
      final barWidth = (plotWidth / dataPoints.length) * 0.6;
      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final isSelected = selectedIndex == i;
        final barPaint = Paint()
          ..color = isSelected ? AppColors.crimson : AppColors.crimson.withValues(alpha: 0.7);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            p.dx - (barWidth / 2),
            p.dy,
            barWidth,
            paddingT + plotHeight - p.dy,
          ),
          const Radius.circular(4),
        );
        canvas.drawRRect(rect, barPaint);
      }
    } else {
      // Smooth Line Chart with Gradient Fill
      final path = Path();
      final fillPath = Path();

      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, paddingT + plotHeight);
      fillPath.lineTo(points.first.dx, points.first.dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
        fillPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }

      fillPath.lineTo(points.last.dx, paddingT + plotHeight);
      fillPath.close();

      // Draw Gradient Fill Under Curve
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.crimson.withValues(alpha: isDark ? 0.25 : 0.15),
            AppColors.crimson.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(paddingL, paddingT, plotWidth, plotHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, gradientPaint);

      // Draw Crimson Line
      final linePaint = Paint()
        ..color = AppColors.crimson
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);

      // Data Point Dots
      if (showDots) {
        final dotFill = Paint()..color = isDark ? AppColors.darkBackground : AppColors.lightBackground;
        final dotStroke = Paint()
          ..color = AppColors.crimson
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        for (int i = 0; i < points.length; i++) {
          final isSelected = selectedIndex == i;
          final radius = isSelected ? 5.5 : 3.5;
          canvas.drawCircle(points[i], radius, dotFill);
          canvas.drawCircle(points[i], radius, dotStroke);

          if (isSelected) {
            final activeDot = Paint()..color = AppColors.crimson;
            canvas.drawCircle(points[i], 3, activeDot);
          }
        }
      }
    }

    // X Axis Labels (First, Middle, Last dates)
    if (dataPoints.isNotEmpty) {
      final dateFormat = DateFormat('MMM d');
      final firstText = dateFormat.format(dataPoints.first.date);
      final lastText = dateFormat.format(dataPoints.last.date);

      _drawText(
        canvas,
        firstText,
        Offset(paddingL, size.height - paddingB + 6),
        textStyle,
        align: TextAlign.left,
      );

      if (dataPoints.length > 2) {
        final midIndex = dataPoints.length ~/ 2;
        final midText = dateFormat.format(dataPoints[midIndex].date);
        _drawText(
          canvas,
          midText,
          Offset(points[midIndex].dx, size.height - paddingB + 6),
          textStyle,
          align: TextAlign.center,
        );
      }

      _drawText(
        canvas,
        lastText,
        Offset(size.width - paddingR, size.height - paddingB + 6),
        textStyle,
        align: TextAlign.right,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double currentX = p1.dx;
    while (currentX < p2.dx) {
      canvas.drawLine(
        Offset(currentX, p1.dy),
        Offset(math.min(currentX + dashWidth, p2.dx), p1.dy),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style,
      {TextAlign align = TextAlign.left}) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = offset.dx;
    if (align == TextAlign.center) {
      dx -= (textPainter.width / 2);
    } else if (align == TextAlign.right) {
      dx -= textPainter.width;
    }

    textPainter.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.dataPoints != dataPoints ||
        oldDelegate.targetValue != targetValue ||
        oldDelegate.isDark != isDark;
  }
}
