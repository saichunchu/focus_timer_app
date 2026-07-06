# Focus Timer — Premium Pomodoro App

A production-quality Flutter Focus Timer / Pomodoro app with a minimal,
premium design, soft purple accents, and smooth animations throughout.

## Tech Stack
- Flutter 3.27+ (uses `Color.withValues`), Riverpod, GoRouter
- Hive (local storage, manual TypeAdapters — no codegen required)
- flutter_local_notifications
- Google Fonts (Plus Jakarta Sans)
- flutter_animate, fl_chart, confetti

## Getting Started

This archive contains the `lib/`, `pubspec.yaml`, and `analysis_options.yaml`
for the app. Since this was built outside of a Flutter SDK environment, you
need to generate the native platform folders once:

```bash
# 1. Install dependencies
flutter pub get

# 2. Run
flutter run
```

`flutter create .` will scaffold `android/`, `ios/`, `web/`, etc. WITHOUT
touching your existing `lib/`, `pubspec.yaml` (it merges — always safe on a
fresh unzip). After that, add these platform-specific permissions:

### Android (`android/app/src/main/AndroidManifest.xml`)
Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS (`ios/Runner/Info.plist`)
No extra keys are required for local notifications beyond the default
project; permission is requested at runtime via
`NotificationService.requestPermissions()`.

## Project Structure (Feature-First + Clean Architecture)

```
lib/
  core/
    constants/       # Hive box names, setting keys, defaults
    theme/            # Colors, text styles, tokens, ThemeData
    router/           # GoRouter config (StatefulShellRoute bottom nav)
    services/         # Hive, Notifications, Haptics
    widgets/          # Shared widgets (shell, bottom nav)
  features/
    home/             # Dashboard: greeting, presets, streak, heatmap preview
    timer/             # Circular timer, session runner, controls
    custom_timers/     # CRUD for user-defined presets
    history/           # Session log, filtering & search
    statistics/         # Charts, streaks, completion rate
    heatmap/            # GitHub-style consistency heatmap
    settings/           # Theme, notifications, strict mode, data export
```

## Build Roadmap (being built incrementally)

- [x] Step 1 — Project scaffold, theme system, Hive models, router, shell nav
- [x] Step 2 — Home screen (full)
- [x] Step 3 — Timer feature (countdown ring, controls, session saving)
- [x] Step 4 — Custom timer presets (CRUD)
- [x] Step 5 — Session history (list, filter, search)
- [x] Step 6 — Statistics (charts, streaks)
- [x] Step 7 — Heatmap (GitHub-style, tap-to-inspect)
- [x] Step 8 — Strict Focus Mode
- [x] Step 9 — Settings (theme, export, reset)
- [ ] Step 10 — Polish pass: animations, confetti, haptics, notifications
