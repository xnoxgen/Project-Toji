import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/audio_feedback.dart';

class RestTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final bool enableSound;
  final bool enableVibration;
  final VoidCallback? onTimerFinished;

  const RestTimerWidget({
    super.key,
    this.initialSeconds = 90,
    this.enableSound = true,
    this.enableVibration = true,
    this.onTimerFinished,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late int _totalDurationSeconds;
  late int _remainingSeconds;
  Timer? _ticker;
  DateTime? _targetEndTime;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _totalDurationSeconds = widget.initialSeconds;
    _remainingSeconds = widget.initialSeconds;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) {
      _remainingSeconds = _totalDurationSeconds;
    }
    _targetEndTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
    _ticker?.cancel();
    setState(() {
      _isRunning = true;
    });

    _ticker = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (_targetEndTime == null) return;
      final diff = _targetEndTime!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
        });
        AudioFeedback.playTimerDoneAlert(
          sound: widget.enableSound,
          vibration: widget.enableVibration,
        );
        widget.onTimerFinished?.call();
      } else {
        if (diff != _remainingSeconds) {
          setState(() {
            _remainingSeconds = diff;
          });
        }
      }
    });
  }

  void _pauseTimer() {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _targetEndTime = null;
    });
  }

  void _resetTimer() {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalDurationSeconds;
      _targetEndTime = null;
    });
  }

  void _setPreset(int seconds) {
    _ticker?.cancel();
    setState(() {
      _isRunning = false;
      _totalDurationSeconds = seconds;
      _remainingSeconds = seconds;
      _targetEndTime = null;
    });
  }

  void _adjustTime(int deltaSeconds) {
    final next = (_remainingSeconds + deltaSeconds).clamp(5, 600);
    setState(() {
      _remainingSeconds = next;
      _totalDurationSeconds = next > _totalDurationSeconds ? next : _totalDurationSeconds;
      if (_isRunning && _targetEndTime != null) {
        _targetEndTime = DateTime.now().add(Duration(seconds: next));
      }
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final progress = _totalDurationSeconds > 0
        ? (_remainingSeconds / _totalDurationSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.crimson),
                  const SizedBox(width: 6),
                  Text(
                    'REST TIMER',
                    style: AppTypography.labelSmall.copyWith(
                      color: textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              // Preset chips
              Row(
                children: [30, 60, 90, 120, 180].map((s) {
                  final isCurrent = _totalDurationSeconds == s;
                  return Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: InkWell(
                      onTap: () => _setPreset(s),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.crimson.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.crimson
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${s}s',
                          style: AppTypography.labelSmall.copyWith(
                            color: isCurrent ? AppColors.crimson : textMuted,
                            fontSize: 10,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Circular timer progress and display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _adjustTime(-15),
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                color: textMuted,
                tooltip: '-15 seconds',
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _remainingSeconds <= 5
                              ? AppColors.warning
                              : AppColors.crimson,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: AppTypography.metricLarge.copyWith(
                            fontSize: 26,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _isRunning ? 'RESTING' : (_remainingSeconds == 0 ? 'READY' : 'PAUSED'),
                          style: AppTypography.labelSmall.copyWith(
                            fontSize: 9,
                            color: _remainingSeconds == 0
                                ? AppColors.success
                                : (_isRunning ? AppColors.crimson : textMuted),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _adjustTime(15),
                icon: const Icon(Icons.add_circle_outline, size: 22),
                color: textMuted,
                tooltip: '+15 seconds',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Timer controls: Start/Pause and Reset
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetTimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Reset', style: TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _pauseTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? AppColors.crimsonDark : AppColors.crimson,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    _isRunning ? 'Pause' : (_remainingSeconds == _totalDurationSeconds ? 'Start Rest' : 'Resume'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

