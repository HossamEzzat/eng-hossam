# Admin Panel & Authentication — Programming with Eng. Hossam

## Admin Login URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:<PORT>/admin/login` |
| GitHub Pages | `https://hossamezzat.github.io/eng-hossam/admin/login` |
| Also works | `/admin` (redirects to login if not authenticated) |

Entry points on the public site:
- Footer → **Admin Login** / **دخول الإدارة** → `/admin/login` only
- Direct URL `/admin/login`

**No admin dashboard or content is shown until email + password succeed.**

---

## Architecture (swap backend later)

```
UI (AdminLoginPage, AdminShell)
        ↓
   AuthService          ← ChangeNotifier, no credentials / SDKs
        ↓
  LoginRepository       ← interface only
        ↓
 LocalDev | Firebase | Supabase | Appwrite | Node | ASP.NET
```

| Layer | File |
|-------|------|
| Temp credentials | `lib/core/config/admin_auth_config.dart` |
| Contract | `LoginRepository` in `admin_auth_repository.dart` |
| UI service | `AuthService` in `admin_auth_controller.dart` |
| Static hosting impl | `LocalDevAdminAuthRepository` |
| Firebase impl | `FirebaseAdminAuthRepository` |
| Wiring | `adminAuthRepositoryProvider` in `admin_providers.dart` |

To switch backends: implement `LoginRepository` and return it from `adminAuthRepositoryProvider`. Do not change login UI.

---

## Temporary credentials (GitHub Pages / local)

`AppConstants.useFirebase = false` — uses `AdminAuthConfig`.

Edit **only** `lib/core/config/admin_auth_config.dart` — never show these values in the UI.

Flow:
1. Footer → Admin Login → empty email + password form
2. Correct credentials → Admin Dashboard
3. Wrong credentials → stay on login, show **Invalid email or password.**

> Client-side config is for development/static hosting only. Anyone can inspect a web build. Replace with Firebase/Supabase/API before treating this as production security.

---

## Route protection

Guarded by GoRouter + `AuthService`:

- `/admin`, `/admin/dashboard` (via `/admin`), `/admin/students`, `/admin/sessions`, `/admin/certificates`, `/admin/reviews`, `/admin/exports`
- Unauthenticated → `/admin/login`
- While restoring session → forced to login (no admin flash)
- Logout → clears session → Home `/`

---

## Firebase Auth mode (production)

### One-time setup

```bash
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
# Enable Email/Password in Firebase Console
# In app_constants.dart: useFirebase = true
firebase deploy --only firestore:rules,storage
```

Then set `adminAuthRepositoryProvider` to return `FirebaseAdminAuthRepository()` (already wired when `useFirebase` is true).

### First admin (Firebase)

Use Firebase Console to create the Auth user and Firestore `admins/{uid}` document. Local/static mode does not use `/admin/setup` bootstrap.

---

## Admin Dashboard (after login)

| Page | Path |
|------|------|
| Dashboard | `/admin` |
| Students | `/admin/students` |
| Sessions | `/admin/sessions` |
| Certificates | `/admin/certificates` |
| Reviews | `/admin/reviews` |
| Exports | `/admin/exports` |

Logout: sidebar → **Logout** → home.

---

## Security checklist

- [x] Footer Admin Login opens `/admin/login` only (not dashboard)
- [x] Login form: email, password, Login — no pre-filled credentials
- [x] No hardcoded `isAdmin = true` bypass
- [x] `/admin/*` redirects guests to `/admin/login`
- [x] Wrong password stays on login with error message
- [x] Logout clears session and returns home
- [x] Auth UI decoupled via `LoginRepository` / `AuthService`
