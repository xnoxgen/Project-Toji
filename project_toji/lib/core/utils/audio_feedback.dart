import 'package:flutter/services.dart';

class AudioFeedback {
  static Future<void> playTimerDoneAlert({
    bool sound = true,
    bool vibration = true,
  }) async {
    if (vibration) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.heavyImpact();
    }
    if (sound) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> playClick({
    bool sound = true,
    bool vibration = true,
  }) async {
    if (vibration) {
      await HapticFeedback.selectionClick();
    }
    if (sound) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> playSuccess({
    bool sound = true,
    bool vibration = true,
  }) async {
    if (vibration) {
      await HapticFeedback.mediumImpact();
    }
    if (sound) {
      await SystemSound.play(SystemSoundType.alert);
    }
  }
}
