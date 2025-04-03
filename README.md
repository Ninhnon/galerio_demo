# Galerio Demo App

A Flutter application with Firebase authentication and WebView integration.

## Environment Setup

1. Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

2. Update the `.env` file with your Firebase configuration:

```env
# Firebase Configuration
FIREBASE_API_KEY=your_api_key_here
FIREBASE_APP_ID_ANDROID=your_android_app_id_here
FIREBASE_APP_ID_IOS=your_ios_app_id_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_IOS_CLIENT_ID=your_ios_client_id_here
FIREBASE_IOS_BUNDLE_ID=your_ios_bundle_id_here
FIREBASE_ANDROID_CLIENT_ID=your_android_client_id_here

# Google Auth Configuration
GOOGLE_WEB_CLIENT_ID=your_web_client_id_here

# App Configuration
WEB_APP_URL=your_web_app_url_here
```

3. Make sure the `.env` file is in your `.gitignore` to prevent committing sensitive data.

## Firebase Configuration

The app uses Firebase Authentication and configuration is managed through environment variables. You can find these values in:

- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Development

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

## Environment Variables

The app uses the following environment variables:

### Firebase Configuration

- `FIREBASE_API_KEY`: Your Firebase API key
- `FIREBASE_APP_ID_ANDROID`: Android app ID from Firebase
- `FIREBASE_APP_ID_IOS`: iOS app ID from Firebase
- `FIREBASE_MESSAGING_SENDER_ID`: Firebase messaging sender ID
- `FIREBASE_PROJECT_ID`: Firebase project ID
- `FIREBASE_STORAGE_BUCKET`: Firebase storage bucket URL
- `FIREBASE_IOS_CLIENT_ID`: iOS client ID for Firebase Auth
- `FIREBASE_IOS_BUNDLE_ID`: iOS bundle identifier
- `FIREBASE_ANDROID_CLIENT_ID`: Android client ID for Firebase Auth

### Google Authentication

- `GOOGLE_WEB_CLIENT_ID`: Web client ID for Google Sign-In

### App Configuration

- `WEB_APP_URL`: URL of the web application to load in WebView

## Notes

- The app will validate all required environment variables on startup
- Missing or invalid configuration will result in an error message
- Make sure to keep your `.env` file secure and never commit it to version control
