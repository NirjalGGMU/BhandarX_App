# BhandarX App Project

BhandarX App Project contains the mobile Flutter client and a dedicated backend for the BhandarX inventory workflow.

This setup is focused on user/employee usage and day-to-day operations: auth, profile, workspace actions, sales flow, and transaction visibility.

## Repository Structure

```text
BhandarX_App_Project/
├── bhandarx_flutter/    # Flutter mobile/web app
└── backend/             # Node.js/Express API for this app
```

## Implemented Mobile Scope

- Auth and Session:
  - Splash, onboarding, login, register
  - Forgot/reset password (OTP flow)
  - Session persistence and logout
- Profile and Settings:
  - My profile, edit profile, change password
  - Dark mode toggle
  - Notification preferences
  - Language toggle (English/Nepali)
- Notifications:
  - Notification list
  - Read/unread handling
  - Mark all read
- Workspace (user/employee-focused):
  - Products: list, search, low-stock/out-of-stock views
  - Customers: list/create/edit/detail
  - Sales/POS: create sale, payment updates, sale detail
  - Transactions: list, recent, summary insights
- UX and Reliability:
  - Offline queue for create customer/sale when network is unavailable
  - Date filters for sales/transactions (All/Today/7d/30d)
  - Role-based route visibility for user scope
- Payment:
  - Cash and QR payment paths in sales flow
  - Sale detail display of payment method/status

## Sensor Features

The app includes sensor support in the mobile codebase for:

- Accelerometer
- Gyroscope

These are designed for runtime use on Android/iOS devices (not reliable on browser builds).

## Backend Scope

The backend under `backend/` includes API modules used by this mobile project, including:

- auth/users
- products/categories
- suppliers/customers
- sales/purchases/transactions
- notifications/activity logs
- dashboard/report endpoints

## Run Backend

```bash
cd backend
npm install
cp .env.mobile.example .env.mobile
npm run dev
```

Default local URL:

```text
http://localhost:5001
http://localhost:5001/api/v1
```

## Run Flutter App

```bash
cd bhandarx_flutter
flutter pub get
flutter run -d chrome
```

For Android emulator/device:

```bash
cd bhandarx_flutter
flutter run -d <android_device_id>
```

## Notes

- Chrome/web cannot fully validate runtime mobile permissions or physical sensors.
- Use Android emulator or physical device for camera/video permission and sensor behavior.
- This project backend is isolated in this repository folder and is intended to avoid affecting other project folders.
