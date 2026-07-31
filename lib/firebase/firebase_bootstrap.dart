import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/firebase/firebase_options.dart';

/// Initializes Firebase when [AppConstants.useFirebase] is true; otherwise no-op.
///
/// 1. Run `flutterfire configure` to fill [DefaultFirebaseOptions]
/// 2. Set `AppConstants.useFirebase = true`
/// 3. Enable Email/Password in Firebase Console → Authentication
Future<void> bootstrapFirebase() async {
  if (!AppConstants.useFirebase) {
    debugPrint('Firebase معطّل — استخدام بيانات تجريبية.');
    return;
  }

  try {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('تم تهيئة Firebase.');
  } catch (e, st) {
    debugPrint('فشل تهيئة Firebase: $e');
    debugPrint('$st');
    debugPrint(
      'Tip: run `flutterfire configure` and set real options in '
      'lib/firebase/firebase_options.dart',
    );
  }
}
