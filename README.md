# HabitAI — World-Class AI Habit Coach & Streak Tracker

Built to Google/Apple quality. 46 Dart files, zero analysis issues.

## Features (ALL implemented — no 'coming soon')
- 5-step onboarding with category selection
- Habit creation with emoji, color, frequency, time-of-day, reminders, measurable goals
- Habit detail with 12-week heatmap, 30-day line chart, insights, notes
- Today view with progress ring, habits grouped by time, animated checkboxes
- Statistics dashboard with heatmap, bar charts, habit rankings
- AI Coach with weekly score, insight cards, chat interface
- Profile with avatar, XP/level system, 26 achievements
- Paywall with 3-tier pricing, feature comparison
- Data export (JSON with clipboard copy)
- Privacy policy
- Dark/Light/System/AMOLED theme modes

## Architecture
- Riverpod 3.x state management
- Hive for local persistence
- Groq AI cloud coaching
- Material 3 design system
- go_router navigation
- Custom animation system

## Run
```bash
flutter pub get
flutter run
flutter build web
flutter build apk
flutter build ipa
```

## Backend: https://habitai-backend.vercel.app
## Web Preview: http://100.119.110.48:5000
