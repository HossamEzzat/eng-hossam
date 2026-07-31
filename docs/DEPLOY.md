# Deploy — Programming with Eng. Hossam

## Live site (GitHub Pages)

**URL:** https://hossamezzat.github.io/eng-hossam/  
**Admin:** https://hossamezzat.github.io/eng-hossam/admin/login  

Repo: https://github.com/HossamEzzat/eng-hossam  

### Redeploy to GitHub Pages

```bash
flutter build web --release --base-href /eng-hossam/ --dart-define=use_arabic=true
# then publish build/web to the gh-pages branch
```

---

# Deploy to Firebase Hosting

Step-by-step production launch (optional alternative to GitHub Pages).

## Prerequisites

- Flutter SDK
- Node.js (for Firebase CLI)
- A Google account + Firebase project

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

## 1. Connect Firebase to the Flutter app

```bash
cd /Users/hossam/StudioProjects/ss
firebase login
flutterfire configure
```

This overwrites `lib/firebase/firebase_options.dart` with real keys.

Edit `.firebaserc`:

```json
{
  "projects": {
    "default": "your-real-project-id"
  }
}
```

In `lib/core/constants/app_constants.dart`:

```dart
static const bool useFirebase = true;
```

Enable **Email/Password** in Firebase Console → Authentication.

## 2. Deploy security rules

```bash
firebase deploy --only firestore:rules,storage
```

## 3. Create the first admin

1. Run locally or open the deployed site
2. Go to `/admin/setup`
3. Create email + password
4. Confirm Firestore has `admins/{uid}` and `config/bootstrap`

## 4. Build & deploy the website

```bash
flutter build web --release
firebase deploy --only hosting
```

Copy the Hosting URL from the CLI output.

## 5. Redeploy later

```bash
flutter build web --release && firebase deploy --only hosting
```
