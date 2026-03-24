# smartfarming

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Firebase Realtime Database

The soil and crop selection screens now listen to live sensor readings
from Firebase Realtime Database. Make sure your ESP32 or other hardware
writes JSON under e.g. `/SensorData` with fields such as `pH`, `ec_value`,
`humidity` and `temperature` (the app maps them to `ph`, `ec`, `sm`, `st`).

After adding the new dependency (`firebase_database`) run:

```bash
flutter pub get
```

and update your security rules so the app can read the data. You can
change the path in the code if your database uses a different key.
