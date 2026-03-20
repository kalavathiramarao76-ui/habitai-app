# HabitAI — World-Class AI Habit Coach

Built to Google/Apple quality standards. 44 Dart files, zero analysis issues.

## Architecture
- **Core**: Design system, models, providers, services, gamification, AI
- **Features**: Onboarding, Home, Stats, Coach, Profile, Paywall
- **State**: Riverpod 3.x (Notifier pattern)
- **Storage**: Hive (habits) + SharedPreferences (settings)
- **AI**: Local rules engine + Groq cloud API
- **Design**: Material 3 with custom theme extensions

## Screens (10)
1. Onboarding (5-step guided setup with category selection)
2. Home (today's habits, progress ring, grouped by time of day)
3. Habit Cards (animated completion, streak tracking)
4. Statistics (heatmap, bar charts, habit rankings)
5. AI Coach (weekly score, insights, chat interface)
6. Profile (achievements grid, XP/level system, settings)
7. Paywall (3-tier pricing, feature comparison)

## Gamification
- XP system (10 base + streak bonus + perfect day + early bird)
- 10 levels (Seed → Universe)
- 26 achievements
- Streak freeze mechanics

## Run
```bash
flutter pub get
flutter run          # device/emulator
flutter build web    # web preview
flutter build apk    # Android
flutter build ipa    # iOS (Mac required)
```

## Backend
https://habitai-backend.vercel.app
