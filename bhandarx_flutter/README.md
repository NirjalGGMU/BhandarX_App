# BhandarX Flutter App

Flutter frontend for BhandarX inventory operations (user/employee scope).

## Main Features

- Auth: splash, onboarding, register, login, forgot/reset password (OTP)
- Profile: view/edit profile, change password, logout
- Notifications: list and read-state handling
- Workspace:
  - Products (list/search/low stock/out of stock)
  - Customers (list/create/edit/detail)
  - Sales/POS (create sale and payment flow)
  - Transactions (history/recent/summary insights)
- Preferences: dark mode, notification toggles, language toggle (EN/NE)
- Offline queue for selected create actions
- QR payment support in sales flow
- Sensor support:
  - Accelerometer
  - Gyroscope

## Tech Stack

- Flutter + Dart
- Riverpod
- Dio
- Hive
- Shared Preferences + Secure Storage

## Run

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Use Android emulator/physical device for runtime permissions and sensor testing.
