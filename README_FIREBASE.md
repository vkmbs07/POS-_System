# Firebase Manual Setup Guide

Since the `firebase` and `flutter` CLI tools are not accessible in your current environment, please follow these steps to manually set up your Firebase backend and connect it to your Retail POS app.

## 1. Create Firebase Project
1.  Go to the [Firebase Console](https://console.firebase.google.com/).
2.  Click **Add project**.
3.  Enter the project name: `retail-pos-app-[random_id]` (e.g., `retail-pos-app-12345`).
4.  Disable Google Analytics (optional, but simpler for now).
5.  Click **Create project**.

## 2. Enable Authentication
1.  In the Firebase Console, go to **Build** > **Authentication**.
2.  Click **Get started**.
3.  Select **Email/Password** from the Sign-in method list.
4.  Enable the **Email/Password** switch.
5.  Click **Save**.

## 3. Enable Cloud Firestore
1.  Go to **Build** > **Firestore Database**.
2.  Click **Create database**.
3.  Select **Production mode**.
4.  Choose a location (e.g., `nam5 (us-central)`).
5.  Click **Enable**.
6.  Go to the **Rules** tab in Firestore.
7.  Copy the content from the `firestore.rules` file in your project root and paste it into the editor.
8.  Click **Publish**.

## 4. Connect to Flutter App (Web)
1.  In the Project Overview, click the **Web** icon (</>) to add a web app.
2.  Register the app with a nickname (e.g., `Retail POS Web`).
3.  You will see a code snippet with `firebaseConfig`. **Keep this page open.**
4.  Open `lib/firebase_options.dart` in your editor.
5.  Replace the placeholder values in `web` section with the values from the `firebaseConfig` object:
    *   `apiKey`
    *   `authDomain`
    *   `projectId`
    *   `storageBucket`
    *   `messagingSenderId`
    *   `appId`
    *   `measurementId`

## 5. Connect to Flutter App (Android) - Optional for now
If you need Android support:
1.  Add an Android app in Firebase Console.
2.  Package name: `com.example.retail_pos_pwa` (check `android/app/build.gradle` -> `applicationId` to be sure).
3.  Download `google-services.json` and place it in `android/app/`.

## 6. Verify
1.  Run your app.
2.  Try to sign up/login.
