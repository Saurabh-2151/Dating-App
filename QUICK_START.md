# 🚀 SparkMatch - Quick Start Guide

## Prerequisites

- Flutter SDK (3.6.1 or higher)
- Dart SDK (3.6.1 or higher)
- Android Studio / VS Code with Flutter extensions
- Firebase project configured (for authentication)

## Installation

### 1. Install Dependencies

```bash
cd "d:\Freelancing Proj\Dating App\Dating-App"
flutter pub get
```

### 2. Firebase Setup

Ensure your Firebase configuration files are in place:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

### 3. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

## 🎨 Premium Features Overview

### Screens Implemented

1. **Splash Screen** - Animated logo with gradient effects
2. **Onboarding Flow** - 10-step premium onboarding
3. **Discover Screen** - Card-based profile browsing
4. **Match Celebration** - Confetti and animations
5. **Premium Subscription** - Pricing plans with features
6. **Home Navigation** - Premium bottom nav with animations

### Key Components

- **Theme System**: `lib/core/theme/app_theme.dart`
- **Premium Colors**: Deep purples, neon pinks, gradients
- **Animations**: Flutter Animate, Confetti, Shimmer
- **Typography**: Google Fonts (DM Sans)

## 🎯 App Flow

```
Splash Screen (3s)
    ↓
Onboarding Flow (10 steps)
    ↓
Auth Wrapper
    ↓
Home Screen
    ├── Discover (Swipe)
    ├── Matches
    ├── Explore
    └── Profile
```

## 🎨 Customization

### Change Primary Color

Edit `lib/core/theme/app_theme.dart`:

```dart
class AppColors {
  static const primary = Color(0xFFFF006E); // Change this
  // ... rest of colors
}
```

### Modify Onboarding Steps

Edit `lib/presentation/features/onboarding/onboarding_flow_screen.dart`

### Update Subscription Plans

Edit `lib/presentation/screens/premium_subscription_screen.dart`:

```dart
final List<Map<String, dynamic>> _plans = [
  // Modify pricing here
];
```

## 🐛 Troubleshooting

### Issue: Dependencies not installing

```bash
flutter clean
flutter pub get
```

### Issue: Firebase errors

Ensure Firebase is properly configured:
```bash
flutterfire configure
```

### Issue: Build errors

```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## 📱 Testing

### Run on Emulator

```bash
# Start Android emulator
flutter emulators --launch <emulator-id>

# Start iOS simulator
open -a Simulator

# Run app
flutter run
```

### Hot Reload

While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

## 🎨 Design Tokens

### Colors
- Primary: `#FF006E`
- Secondary: `#FF4D8D`
- Background: `#0A0A0A`
- Card: `#1A1A1A`

### Spacing
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

### Border Radius
- Small: 12px
- Medium: 16px
- Large: 20px
- Pill: 28px

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Setup](https://firebase.google.com/docs/flutter/setup)
- [Flutter Animate](https://pub.dev/packages/flutter_animate)
- [Google Fonts](https://pub.dev/packages/google_fonts)

## 🎉 Next Steps

1. **Configure Firebase** - Set up authentication
2. **Add Profile Images** - Implement image picker
3. **Chat Feature** - Build messaging system
4. **Push Notifications** - Firebase Cloud Messaging
5. **Analytics** - Track user engagement
6. **Testing** - Write unit and widget tests

## 💡 Tips

- Use hot reload for faster development
- Test on both Android and iOS
- Optimize images for performance
- Follow Material Design guidelines
- Keep animations smooth (60fps)

---

**Need Help?** Check the `PREMIUM_REDESIGN_SUMMARY.md` for detailed design documentation.
