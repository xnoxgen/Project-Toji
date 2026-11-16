# PHYSIQUE — Personal Fitness Tracker (Project Toji)

A minimal, high-performance personal fitness tracker designed with a **Lamp Black (`#121212`) + Crimson Red (`#DC143C`)** aesthetic. Built for progressive overload training, precise body measurement tracking, and physique transformation.

Works 100% offline with persistent local storage, zero accounts, and zero cloud dependencies.

---

## Features

- **Lamp Black & Crimson Theme**: Dark mode (default) and clean off-white light mode with persistent toggle in Settings.
- **Initial Onboarding & Profile**: Collects athlete baseline, body circumferences, fitness goals, and ideal target physique measurements.
- **Home Dashboard**: Displays today's workout, daily completion percentage, workout streak, body weight, latest waist measurement, and weekly training activity.
- **Weekly Workout Planner**: 7-day routine planner (Mon–Sun) pre-seeded with the Toji progressive overload split. Includes a searchable 60+ exercise library across 9 muscle groups, custom exercise creation, reordering, and duplication.
- **Workout Execution Screen**: Exercise cards with quick **"Complete" / "Completed"** toggle buttons, per-set weight inputs (+/- 2.5kg / 5kg), actual reps completed, and workout summary statistics with undo support.
- **Background-Accurate Rest Timer**: Quick presets (30s, 60s, 90s, 120s, 180s), custom +/- 15s adjustments, timestamp-based background accuracy, and audio/haptic completion alerts.
- **Streak & Consistency Tracker**: Current streak, longest streak, total completed sessions, and interactive monthly calendar highlighting active workout days.
- **Progress & Analytics**: High-DPI interactive cubic bezier charts with gradient fills, period selectors (7d, 30d, 3m, 6m, 1y), target comparison lines, and date-based measurement history.
- **Weekly Check-In System**: 7-day review prompt to record weight, waist, chest, biceps, consistency, and energy/recovery ratings.
- **Offline Local Persistence & Backups**: Instant JSON export and restore for full data backups and migrations.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.13+ or higher)
- Supported platforms: Android, iOS, Web (Chrome / Edge), Windows, macOS, Linux

### Installation & Run

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
# Web
flutter run -d edge

# Android / Desktop
flutter run
```

3. Run tests:
```bash
flutter test
```

---

## License

Distributed under the MIT License. See `LICENSE` for more information.
