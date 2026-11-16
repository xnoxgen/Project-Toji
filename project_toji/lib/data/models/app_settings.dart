class AppSettings {
  final String themeMode; // 'dark', 'light'
  final int defaultRestSeconds;
  final bool enableSound;
  final bool enableVibration;
  final bool hasCompletedOnboarding;
  final DateTime? lastCheckInDate;
  final DateTime? dismissedCheckInUntil;

  const AppSettings({
    this.themeMode = 'dark',
    this.defaultRestSeconds = 90,
    this.enableSound = true,
    this.enableVibration = true,
    this.hasCompletedOnboarding = false,
    this.lastCheckInDate,
    this.dismissedCheckInUntil,
  });

  AppSettings copyWith({
    String? themeMode,
    int? defaultRestSeconds,
    bool? enableSound,
    bool? enableVibration,
    bool? hasCompletedOnboarding,
    DateTime? lastCheckInDate,
    DateTime? dismissedCheckInUntil,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      dismissedCheckInUntil:
          dismissedCheckInUntil ?? this.dismissedCheckInUntil,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'defaultRestSeconds': defaultRestSeconds,
      'enableSound': enableSound,
      'enableVibration': enableVibration,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'lastCheckInDate': lastCheckInDate?.toIso8601String(),
      'dismissedCheckInUntil': dismissedCheckInUntil?.toIso8601String(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: json['themeMode'] as String? ?? 'dark',
      defaultRestSeconds: (json['defaultRestSeconds'] as num?)?.toInt() ?? 90,
      enableSound: json['enableSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      hasCompletedOnboarding:
          json['hasCompletedOnboarding'] as bool? ?? false,
      lastCheckInDate: json['lastCheckInDate'] != null
          ? DateTime.parse(json['lastCheckInDate'] as String)
          : null,
      dismissedCheckInUntil: json['dismissedCheckInUntil'] != null
          ? DateTime.parse(json['dismissedCheckInUntil'] as String)
          : null,
    );
  }
}

