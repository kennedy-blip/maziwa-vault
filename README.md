# MaziwaVault

MaziwaVault is an offline-first dairy cooperative operations app built with Dart + Flutter. It records farmer milk intake, quality decisions, feed-credit advances and estimated payouts.

## Features

- AM / PM milk collection ledger with liters, density readings and accepted / rejected quality outcomes.
- Farmer register with member ID, route, herd count and optional contact.
- Agrovet, dairy meal, mineral salt and service advances tracked per farmer.
- Payout calculations: accepted liters × cooperative rate − recorded advances.
- Chilling tank utilization, payout status and member summaries.
- Manager and route-clerk UI roles, three themes and responsive navigation.
- Local device persistence using shared_preferences; JSON backup copied to clipboard.
- GitHub Actions builds Flutter Web (Wasm) and Android release APKs.

## Run locally

Install the current stable Flutter SDK, then from the repository root:

    flutter create --platforms=android,web --project-name maziwa_vault .
    flutter pub get
    flutter run

## Build

    flutter build web --release --wasm
    flutter build apk --release

The APK is produced at build/app/outputs/flutter-apk/app-release.apk. GitHub Actions publishes it as the app-release.apk asset on the repository's latest release after a push to main.

## Vercel

Import this repository into Vercel. The committed vercel.json installs the stable Flutter SDK, generates the Web platform files, builds with flutter build web --release --wasm, and serves build/web.

## Data and operational notes

- Data is stored on the current browser/device only. This initial release does not synchronize records across devices or cooperatives.
- The role selector is an in-app workflow restriction, not server-enforced authentication. Use it as an operational UI control, not as a security boundary.
- Quality readings are recorded for traceability; configure acceptance thresholds and calibrate lactometers under your cooperative's approved procedures.
- Payout figures are estimates from the current local ledger. Confirm rates, deductions and member balances before disbursement.
- Back up JSON exports securely. Shared-device browser storage can be cleared by browser settings.
