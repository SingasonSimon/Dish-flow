# Dish Flow

A modern cross-platform mobile app for browsing, uploading, and discovering food recipes with a premium iOS-inspired UI design.

## Features

- 🔐 Firebase Authentication (Email/Password + Google Sign-In)
- 📝 Recipe browsing and discovery
- 📤 Recipe upload with image support
- ❤️ Like and save recipes
- ⭐ Review and rate recipes
- 👤 User profiles with stats
- 🎨 Premium iOS-inspired UI design
- 📱 Cross-platform (iOS + Android)

## Tech Stack

- **Flutter** - Cross-platform framework
- **Riverpod** - State management
- **Firebase Auth** - Authentication
- **Cloud Firestore** - Database
- **Cloudinary** - Image hosting
- **Firebase Cloud Messaging** - Push notifications

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App constants
│   ├── theme/         # Theme configuration
│   └── utils/         # Utility files
├── features/
│   ├── auth/          # Authentication screens
│   ├── home/          # Home feed screen
│   ├── recipes/       # Recipe screens
│   ├── profile/       # Profile screen
│   └── reviews/       # Review functionality
├── models/            # Data models
├── providers/         # Riverpod providers
├── routes/            # Navigation configuration
├── services/          # Firebase, Cloudinary services
└── widgets/           # Reusable widgets
```

## Setup Instructions

### Prerequisites

- Flutter SDK (>=3.0.0)
- Firebase project configured
- Cloudinary account (for image uploads)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd Dish-Flow
```

2. Install dependencies:
```bash
flutter pub get
```

3. **Generate Firebase Options** (Required):
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   This creates `lib/core/utils/firebase_options.dart` with your Firebase credentials.
   
   **⚠️ Security Note**: `firebase_options.dart` is in `.gitignore` - each developer must generate their own. See [SECURITY.md](SECURITY.md) for details.

4. Configure Firebase config files:
   - Android: `google-services.json` should be in `android/app/`
   - iOS: `GoogleService-Info.plist` should be in `ios/Runner/`
   - These are typically committed (contain public client keys)

5. Configure Cloudinary:
   - Update `lib/services/cloudinary_service.dart` with your Cloudinary credentials:
     - `cloudName`
     - `apiKey`
     - `apiSecret`
     - `uploadPreset`

5. Run the app:
```bash
flutter run
```

## Firebase Setup

The Firebase configuration files are already in place:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Make sure your Firebase project has:
- Authentication enabled (Email/Password + Google)
- Firestore Database enabled
- Cloud Messaging enabled

## Cloudinary Setup

1. Create a Cloudinary account at https://cloudinary.com
2. Get your credentials from the dashboard
3. Update `lib/services/cloudinary_service.dart` with your credentials
4. Create an upload preset (unsigned) for easier uploads

## Development Phases

- ✅ Phase 1: Project scaffold, Firebase setup, folder structure
- ✅ Phase 2: UI screens (static), navigation system
- ✅ Phase 3: Auth integration (Firebase + Google Sign-In)
- ✅ Phase 4: Firestore models + data flow
- ✅ Phase 5: Image upload → Cloudinary
- ✅ Phase 6: Likes, reviews, personalization
- ⏳ Phase 7: Polish UI, animations, performance, deploy

## Notes

- The app uses Riverpod for state management
- UI design is inspired by Apple's Human Interface Guidelines
- All screens are responsive for both iOS and Android
- Image uploads are handled through Cloudinary
- Real-time updates use Firestore streams

## License

This project is private and proprietary.
