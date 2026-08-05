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

## Single owner-admin

There is **exactly one** admin account: Eng. Hossam.

- No public signup / setup of additional admins
- Login at `/admin/login` with that one email + password
- Credentials live only in `lib/core/config/admin_auth_config.dart` (never shown in UI)

Edit email/password in that config file, rebuild, and redeploy.

---

## Route protection

Guarded by GoRouter + `AuthService`:

- `/admin`, `/admin/dashboard` (via `/admin`), `/admin/students`, `/admin/sessions`, `/admin/certificates`, `/admin/reviews`, `/admin/exports`
- Unauthenticated → `/admin/login`
- While restoring session → forced to login (no admin flash)
- Logout → clears session → Home `/`

---

## Firebase Auth mode (production)

See **[`docs/FIREBASE.md`](FIREBASE.md)** (project `eng-hossam-app`).

Today:
- `useFirebase = true` → registrations live in Firestore
- `useFirebaseAuth = false` → admin still uses `admin_auth_config.dart` until you enable Email/Password in Console and set `useFirebaseAuth = true`

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
