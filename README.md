# Programming with Eng. Hossam / بشمهندس حسام

Premium Flutter Web platform (Arabic default + English), dark theme only.

## Run

```bash
flutter gen-l10n
flutter run -d chrome
```

## Branding

- AR: بشمهندس حسام  
- EN: Eng. Hossam  

## Locales

ARB files in `lib/l10n/` — switcher in navbar.

### Admin access

1. Open **`/admin/login`**
2. Sign in with the owner email/password in `lib/core/config/admin_auth_config.dart`
3. Students list syncs from **Firebase** (`eng-hossam-app`) when `useFirebase` is true

Firebase setup: [`docs/FIREBASE.md`](docs/FIREBASE.md)  
Admin guide: [`docs/ADMIN.md`](docs/ADMIN.md)

Admin pages: Dashboard · Students · Sessions · **Certificates (preview)** · Reviews · Exports

