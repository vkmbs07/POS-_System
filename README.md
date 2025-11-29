# Retail POS & Inventory PWA

A Flutter-based Progressive Web App (PWA) designed for mid-level retail shops. Features offline-first architecture, dual-scanning modes (Camera & USB), and Web Bluetooth printing.

## Features

- **POS Terminal**: Split-screen layout for high-speed billing.
- **Dual Scanning**:
  - **USB Mode**: Supports hardware barcode scanners via keyboard input.
  - **Camera Mode**: Uses device camera to scan QR/Barcodes.
- **Inventory Management**: Add, edit, and track products.
- **Offline First**: Works without internet using Firestore persistence.
- **Printing**: Connects to thermal printers via Web Bluetooth.

## Setup

1.  **Firebase Configuration**:
    - Create a project in Firebase Console.
    - Enable **Firestore Database** and **Authentication**.
    - Run `flutterfire configure` to generate `firebase_options.dart`.
    - Uncomment the Firebase initialization code in `lib/main.dart`.

2.  **Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Running the App**:
    - For Chrome (Web):
      ```bash
      flutter run -d chrome --web-port 55555 --web-renderer html
      ```
      *Note: Web Bluetooth requires a secure context (HTTPS) or `localhost`.*

4.  **Installing as PWA**:
    - Once the app is running in Chrome:
    - Look for the **Install icon** (computer with down arrow) in the address bar.
    - Click **Install**.
    - The app will now launch as a standalone desktop application.

## Architecture

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Database**: Cloud Firestore (Offline Persistence Enabled)

## Usage

### Scanning
- Toggle between **Camera** and **USB** modes using the switch in the AppBar.
- In **USB Mode**, simply scan a barcode with your hardware scanner. The app listens for rapid keystrokes ending in `Enter`.
- In **Camera Mode**, point the camera at a barcode.

### Printing
- Ensure your thermal printer supports **Web Bluetooth**.
- Click **Checkout & Print** to search for and connect to the printer.
