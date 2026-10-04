# Meezan Mobile — Educational UI Clone (Flutter)

An **unofficial, educational Flutter recreation** of the look & feel of a Pakistani
Islamic banking app (Meezan Bank style). Built for learning Flutter UI patterns,
state management and CI/CD.

> ## ⚠️ Disclaimer — Read Before Use
> - This project is **NOT affiliated with, endorsed by, or connected to Meezan Bank Limited**.
> - It contains **NO real banking functionality**. All accounts, balances, beneficiaries
>   and transactions are **hard-coded mock/demo data**.
> - The emblem and branding here are **original approximations drawn in code**, not the
>   official trademarked logo.
> - **Never** enter real banking credentials into this app.
> - **Never** redistribute a lookalike banking app to deceive anyone — that is illegal
>   (fraud/phishing). This repository exists purely for Flutter UI/UX education.

[![Build Android APK](https://github.com/faisukhan01/meezan/actions/workflows/android.yml/badge.svg)](https://github.com/faisukhan01/meezan/actions/workflows/android.yml)
[![Download APK](https://img.shields.io/badge/Download-APK-green)](https://github.com/faisukhan01/meezan/releases/latest)

---

## Features

| Area | What's included |
|---|---|
| Splash & Auth | Branded splash, login with validation, demo biometric login, session persistence |
| Dashboard | Greeting header, multi-account balance card (hide/show), account switcher chips, 6 quick actions |
| Accounts | Account list, total PKR balance, detail page with IBAN copy, mini statement |
| Transfers | 3 modes — Within Meezan / IBFT (16 banks) / Raast (mobile ID), saved beneficiaries, add beneficiary, purpose of payment, OTP verification (demo OTP `123456`), animated receipt |
| Payments | 8 bill categories & 20 billers, consumer-number bill form, mobile top-up for Jazz/Zong/Telenor/Ufone, receipts |
| Raast QR | Decorative QR card generated with CustomPaint |
| More | Profile card, cards/statements/cheque-book demo actions, settings (light/dark/system theme, biometrics, hide balances, notifications), logout flow |
| Platform | Material 3, light & dark themes, adaptive launcher icon, splash screen |

## Tech Stack

- **Flutter 3.24 / Dart 3.5** — single codebase → native Android APK
- **Provider** — state management (`AppState` with `ChangeNotifier`)
- **shared_preferences** — session & settings persistence
- **intl** — PKR currency / date formatting
- **GitHub Actions** — CI that builds `app-release.apk` on every push to `main`
  and publishes it to the [Releases page](https://github.com/faisukhan01/meezan/releases/latest)

## Project Structure

```
lib/
├── main.dart                  # App entry, providers, theming
├── core/
│   ├── theme.dart             # Meezan-style green/gold design system
│   └── format.dart            # money(), masking, date helpers
├── data/
│   ├── models.dart            # Account, Txn, Beneficiary, Biller, drafts
│   └── mock_data.dart         # All demo data (no real bank connectivity)
├── state/
│   └── app_state.dart         # Auth, transfers, bills, settings (ChangeNotifier)
├── widgets/
│   └── common.dart            # Emblem painter, balance card, tiles, receipt page
└── screens/
    ├── splash.dart  login.dart  shell.dart  home.dart
    ├── accounts.dart  transfer.dart (incl. OTP)  payments.dart
    ├── more.dart (incl. settings)  qr.dart
android/                       # Flutter Android host (Gradle 8.3 / AGP 8.1 / Kotlin 1.8.22)
.github/workflows/android.yml  # APK build + release pipeline
```

## Build Locally

```bash
flutter pub get
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Or just push to `main` — CI builds the APK automatically and attaches it to the
`latest-apk` GitHub Release.

## Demo Credentials

- Username: **any** non-empty string
- Password: **any** string with 4+ characters
- OTP: **123456**

## License

Code is provided for educational purposes. "Meezan" and the official Meezan Bank
logo/brand are trademarks of Meezan Bank Limited — this project claims no rights
over them and uses only an original lookalike-free emblem.
