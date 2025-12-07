# Dish Flow

A modern cross-platform mobile app for browsing, uploading, and discovering food recipes with a premium iOS-inspired UI design.

## Features

- Firebase Authentication (Email/Password + Google Sign-In)
- Recipe browsing and discovery
- Recipe upload with image support
- Like and save recipes
- Review and rate recipes
- User profiles with stats
- Premium iOS-inspired UI design
- Cross-platform (iOS + Android)

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
git clone https://github.com/SingasonSimon/Dish-flow.git
cd Dish-Flow
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Firebase Options (Required):
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   This creates `lib/core/utils/firebase_options.dart` with your Firebase credentials.
   
   **Security Note**: `firebase_options.dart` is in `.gitignore` - each developer must generate their own.

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

6. Run the app:
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
- Cloud Messaging enabled (optional)

### Firestore Security Rules

Set up these security rules in Firestore Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Recipes collection
    match /recipes/{recipeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.authorId == request.auth.uid;
      
      // Likes subcollection
      match /likes/{likeId} {
        allow read: if request.auth != null;
        allow write: if request.auth != null;
      }
    }
    
    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // User saves subcollection
    match /users/{userId}/saves/{saveId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

## Cloudinary Setup

1. Create a Cloudinary account at https://cloudinary.com
2. Get your credentials from the dashboard
3. Update `lib/services/cloudinary_service.dart` with your credentials
4. Create an upload preset (unsigned) for easier uploads:
   - Go to Settings > Upload
   - Create new upload preset
   - Set it as "Unsigned"
   - Set folder: `dish_flow/recipes`
   - Set transformations: `w_800,h_600,c_fill,q_auto`

## Development Status

- Phase 1: Project scaffold, Firebase setup, folder structure - Complete
- Phase 2: UI screens (static), navigation system - Complete
- Phase 3: Auth integration (Firebase + Google Sign-In) - Complete
- Phase 4: Firestore models + data flow - Complete
- Phase 5: Image upload to Cloudinary - Complete
- Phase 6: Likes, reviews, personalization - Complete
- Phase 7: Polish UI, animations, performance, deploy - In Progress

## Architecture

- **State Management**: Riverpod for reactive state management
- **Navigation**: GoRouter for declarative routing
- **UI Design**: Inspired by Apple's Human Interface Guidelines
- **Responsive**: All screens adapt to both iOS and Android
- **Real-time**: Firestore streams for live data updates
- **Image Handling**: Cloudinary for optimized image hosting

## Security

- Firebase API keys are client-side (safe to expose in mobile apps)
- Cloudinary API Secret should never be exposed - use upload presets
- `firebase_options.dart` is gitignored - generate locally using FlutterFire CLI
- Environment variables (`.env`) are gitignored
- Firestore Security Rules protect backend data

## Troubleshooting

### Firebase Not Initializing
- Check that `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Verify Firebase project settings match the config files
- Run `flutter clean` and `flutter pub get`
- Generate `firebase_options.dart` using `flutterfire configure`

### Cloudinary Upload Fails
- Verify credentials in `cloudinary_service.dart`
- Check upload preset is set to "Unsigned"
- Verify network permissions in AndroidManifest.xml

### Images Not Loading
- Check Cloudinary URLs are correct
- Verify `cached_network_image` package is working
- Check network connectivity

## License

This project is private and proprietary.
