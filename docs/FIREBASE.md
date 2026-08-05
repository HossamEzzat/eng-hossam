# Firebase — Eng. Hossam (`eng-hossam-app`)

Live site still deploys to **GitHub Pages**. Firebase is the **data + (optional) admin auth** backend.

## Project

| Field | Value |
|-------|--------|
| Project ID | `eng-hossam-app` |
| Console | https://console.firebase.google.com/project/eng-hossam-app/overview |
| Web app | Eng Hossam Web |
| Options file | `lib/firebase/firebase_options.dart` |

## What is already done

- [x] Firebase project created
- [x] Web app + `firebase_options.dart` filled with real keys
- [x] Firestore `(default)` database (`eur3`)
- [x] Security rules + indexes deployed
- [x] App flag `AppConstants.useFirebase = true` (Firestore is source of truth)
- [x] Registration writes to `registrations/{id}`
- [x] Admin Students list syncs from Firestore (refresh button)

## Console steps you must finish (Auth)

Firebase **Authentication** is not initialized yet (`CONFIGURATION_NOT_FOUND` until you open it once).

1. Open [Authentication](https://console.firebase.google.com/project/eng-hossam-app/authentication)
2. Click **Get started**
3. Enable **Email/Password** (sign-in method)
4. **Authentication → Users → Add user**
   - Email: `hossamezzat199@gmail.com`
   - Password: same as in `lib/core/config/admin_auth_config.dart` (or a new one you will use)
5. Copy the new user’s **UID**
6. In **Firestore → Data**, create document `admins/{UID}`:

```json
{
  "uid": "<PASTE_UID>",
  "email": "hossamezzat199@gmail.com",
  "name": "Eng. Hossam",
  "role": "admin",
  "createdAt": "<timestamp or ISO string>"
}
```

7. In `lib/core/constants/app_constants.dart` set:

```dart
static const bool useFirebaseAuth = true;
```

8. Rebuild + redeploy GitHub Pages (see below)

Until step 7, admin login still uses the **local** owner password in `admin_auth_config.dart`, while student data already syncs via Firestore.

## How data flows

```
Student phone/browser
  → Register form
  → SessionRepository.register()
  → Firestore registrations/{id}
  → (same browser) SessionStore cache

Admin (any device)
  → /admin/login
  → Students page / syncFromRemote()
  → reads Firestore registrations
  → SessionStore for UI
```

**Past registrations that only lived in one browser’s localStorage cannot be recovered** into Firestore. New signups after this deploy are shared.

## Security rules (summary)

| Collection | Public | Admin |
|------------|--------|-------|
| `registrations` | create (validated fields), read (certificate/journey), limited journey field updates | full update/delete |
| `reviews` | create; read approved | moderate |
| `admins` / `config/bootstrap` | — | role docs; first admin bootstrap |
| `sessions` / `settings` | read | write |

Registrations are readable so certificate lookup works from any phone. Deletes and attendance/certificate **admin** edits require an admin session (or local admin mode today).

Redeploy rules:

```bash
firebase deploy --only firestore:rules,firestore:indexes --project eng-hossam-app
```

## Deploy site (GitHub Pages)

```bash
flutter build web --release --base-href /eng-hossam/ --dart-define=use_arabic=true --no-wasm-dry-run
# then force-push build/web to origin gh-pages
```

## Optional: switch admin to Firebase Auth

After Console Auth steps above and `useFirebaseAuth = true`, login uses Firebase Auth + `admins/{uid}` check (`FirebaseAdminAuthRepository`).
