// File generated for Firebase project eng-hossam-app (web).
// Regenerate with: flutterfire configure --project=eng-hossam-app
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. '
          'Run: flutterfire configure --project=eng-hossam-app',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOPPu9t9TdtSXRqTc3MW8OJ5RmRSxUGEM',
    appId: '1:240016919185:web:c0d6714cc6b7dd5e778d30',
    messagingSenderId: '240016919185',
    projectId: 'eng-hossam-app',
    authDomain: 'eng-hossam-app.firebaseapp.com',
    storageBucket: 'eng-hossam-app.firebasestorage.app',
  );

  /// Same web project keys until native apps are configured.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOPPu9t9TdtSXRqTc3MW8OJ5RmRSxUGEM',
    appId: '1:240016919185:web:c0d6714cc6b7dd5e778d30',
    messagingSenderId: '240016919185',
    projectId: 'eng-hossam-app',
    storageBucket: 'eng-hossam-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDOPPu9t9TdtSXRqTc3MW8OJ5RmRSxUGEM',
    appId: '1:240016919185:web:c0d6714cc6b7dd5e778d30',
    messagingSenderId: '240016919185',
    projectId: 'eng-hossam-app',
    storageBucket: 'eng-hossam-app.firebasestorage.app',
    iosBundleId: 'com.example.lumina',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDOPPu9t9TdtSXRqTc3MW8OJ5RmRSxUGEM',
    appId: '1:240016919185:web:c0d6714cc6b7dd5e778d30',
    messagingSenderId: '240016919185',
    projectId: 'eng-hossam-app',
    storageBucket: 'eng-hossam-app.firebasestorage.app',
    iosBundleId: 'com.example.lumina',
  );
}
