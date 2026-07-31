# Admin Panel & Deployment — Programming with Eng. Hossam

## Admin Login URL

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:<PORT>/admin/login` |
| Also works | `http://localhost:<PORT>/admin` (redirects to login if needed) |
| Production | `https://YOUR_PROJECT_ID.web.app/admin/login` |

Entry points on the public site:
- Footer → **Admin Login** / **دخول الإدارة**
- Direct URL `/admin/login`

Admin pages are **fully separate** from the student site and guarded by GoRouter.

---

## Demo mode credentials (current default)

`AppConstants.useFirebase = false` — works offline without Firebase.

| Field | Value |
|-------|--------|
| Email | `admin@enghossam.app` |
| Password | `admin123` |

1. Open `/admin/login` (or footer → Admin Login)
2. Credentials are pre-filled
3. Click **Enter dashboard**

Students cannot access `/admin/*` without this login. Wrong credentials or non-admin accounts show **Access Denied** and return home.

---

## Firebase Auth mode (production)

### One-time setup

```bash
# 1) Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 2) Login + select your Firebase project (creates real firebase_options.dart)
firebase login
flutterfire configure

# 3) Put your project id in .firebaserc
# 4) Enable Email/Password in Firebase Console → Authentication → Sign-in method

# 5) In lib/core/constants/app_constants.dart set:
#    static const bool useFirebase = true;

# 6) Deploy security rules
firebase deploy --only firestore:rules,storage
```

### First admin account (Firebase)

When no admin exists yet:

1. Open `/admin/setup`
2. Enter name, email, password (min 6 characters)
3. App creates:
   - Firebase Auth user (email/password)
   - Firestore `admins/{uid}` with `{ uid, email, name, role: "admin", createdAt }`
   - Firestore `config/bootstrap` with `{ adminCreated: true }`
4. You are signed in and redirected to `/admin`

Suggested first account:

| Field | Suggested value |
|-------|-----------------|
| Email | `admin@enghossam.app` (or your Gmail) |
| Password | Choose a strong password (store it safely) |
| Name | Eng. Hossam |

### How to add more admins later

1. Firebase Console → **Authentication** → Add user (email + password)
2. Copy the new user’s **UID**
3. Firestore → collection `admins` → document ID = that UID:

```json
{
  "uid": "<UID>",
  "email": "second@example.com",
  "name": "Second Admin",
  "role": "admin",
  "createdAt": "<timestamp>"
}
```

They can then sign in at `/admin/login`.

---

## Admin Dashboard (after login)

| Page | Path | What you can do |
|------|------|-----------------|
| Dashboard | `/admin` | Live stats & charts |
| Students | `/admin/students` | Search, filter, attendance, certificates, bulk actions |
| Sessions | `/admin/sessions` | Create/edit sessions, open/close registration |
| Certificates | `/admin/certificates` | Preview + download PDF |
| Reviews | `/admin/reviews` | Approve / hide / delete |
| Exports | `/admin/exports` | CSV, Excel, attendance PDF |

Logout: sidebar → **Logout**

---

## Firebase Hosting — deploy the website

Config files (already in the repo):

- `firebase.json` — Hosting → `build/web`, SPA rewrite, Firestore/Storage rules paths
- `.firebaserc` — set `"default"` to your Firebase project ID
- `firebase/firestore.rules` — admin-gated rules
- `firebase/storage.rules`
- `lib/firebase/firebase_options.dart` — filled by `flutterfire configure`

### Exact commands

```bash
# From the project root: /Users/hossam/StudioProjects/ss

# 1) Build Flutter Web (release)
flutter build web --release

# 2) Firebase CLI login (once per machine)
firebase login

# 3) Set your project id in .firebaserc, OR:
firebase use --add
# (select your project)

# 4) Optional first-time init if you prefer the wizard:
# firebase init hosting
# → public directory: build/web
# → single-page app: Yes
# → do NOT overwrite index.html

# 5) Deploy
firebase deploy

# Or hosting only:
firebase deploy --only hosting

# Rules + hosting:
firebase deploy --only hosting,firestore:rules,storage
```

### Public URL after deploy

Firebase prints something like:

```
Hosting URL: https://YOUR_PROJECT_ID.web.app
Also:        https://YOUR_PROJECT_ID.firebaseapp.com
```

Admin: `https://YOUR_PROJECT_ID.web.app/admin/login`

### Custom domain later

1. Firebase Console → Hosting → **Add custom domain**
2. Enter your domain (e.g. `enghossam.com`)
3. Add the DNS records Firebase shows (A / TXT)
4. Wait for SSL provisioning

### Redeploy after changes

```bash
flutter build web --release
firebase deploy --only hosting
```

---

## Security checklist

- [x] `/admin/*` redirects guests to `/admin/login`
- [x] Non-admin Firebase users → Access Denied → home
- [x] Students use public routes only (`/`, `/register`, …)
- [x] Footer Admin Login opens dedicated login page
- [x] Firestore rules: admin writes gated by `admins/{uid}`
- [x] First admin bootstrap via `/admin/setup` (Firebase mode)
- [x] Hosting SPA rewrite for Flutter Web deep links
