# Dish Flow - Setup Guide

## Quick Start

1. **Install Flutter Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Cloudinary**
   - Open `lib/services/cloudinary_service.dart`
   - Replace the placeholder values:
     - `cloudName`: Your Cloudinary cloud name
     - `apiKey`: Your Cloudinary API key
     - `apiSecret`: Your Cloudinary API secret (for signed uploads)
     - `uploadPreset`: Your upload preset name (recommended: create an unsigned preset)

3. **Firebase Configuration**
   - Android: `google-services.json` is already in `android/app/`
   - iOS: `GoogleService-Info.plist` is already in `ios/Runner/`
   - Make sure Firebase project has:
     - Authentication enabled (Email/Password + Google)
     - Firestore Database enabled
     - Cloud Messaging enabled (optional)

4. **Run the App**
   ```bash
   flutter run
   ```

## Cloudinary Setup Steps

1. Sign up at https://cloudinary.com
2. Go to Dashboard → Settings
3. Copy your Cloud Name, API Key, and API Secret
4. Create an Upload Preset:
   - Go to Settings → Upload
   - Click "Add upload preset"
   - Set it as "Unsigned" (for easier client-side uploads)
   - Set folder: `dish_flow/recipes`
   - Set transformations: `w_800,h_600,c_fill,q_auto`
5. Update `lib/services/cloudinary_service.dart` with your credentials

## Firebase Firestore Rules

Set up these security rules in Firestore:

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

## Android Configuration

The Android configuration is already set up:
- `android/app/build.gradle` - Firebase and dependencies
- `android/app/src/main/AndroidManifest.xml` - Permissions
- `android/app/google-services.json` - Firebase config

## iOS Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure `GoogleService-Info.plist` is in the Runner folder
3. Add the following to `ios/Runner/Info.plist`:
   ```xml
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need access to your photos to upload recipe images</string>
   <key>NSCameraUsageDescription</key>
   <string>We need access to your camera to take recipe photos</string>
   ```

## Testing

1. **Test Authentication**
   - Register a new account
   - Login with email/password
   - Test Google Sign-In
   - Test password reset

2. **Test Recipe Features**
   - Upload a recipe with image
   - Browse recipes in feed
   - View recipe details
   - Like and save recipes
   - Add reviews

3. **Test Profile**
   - View user stats
   - See uploaded recipes
   - Logout functionality

## Troubleshooting

### Firebase Not Initializing
- Check that `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Verify Firebase project settings match the config files
- Run `flutter clean` and `flutter pub get`

### Cloudinary Upload Fails
- Verify credentials in `cloudinary_service.dart`
- Check upload preset is set to "Unsigned"
- Verify network permissions in AndroidManifest.xml

### Images Not Loading
- Check Cloudinary URLs are correct
- Verify `cached_network_image` package is working
- Check network connectivity

## Next Steps

- Add app icons and splash screens
- Configure push notifications (Firebase Cloud Messaging)
- Add search functionality
- Implement recipe recommendations
- Add social sharing features
- Performance optimization and testing

