import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/firebase/firebase_options.dart';

/// Initializes Firebase when [AppConstants.useFirebase] is true; otherwise no-op.
///
/// Project: `eng-hossam-app` — see `docs/FIREBASE.md`.
Future<void> bootstrapFirebase() async {
  if (!AppConstants.useFirebase) {
    debugPrint('Firebase off — local cache only.');
    return;
  }

  try {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase ready (${DefaultFirebaseOptions.web.projectId}).');
  } catch (e, st) {
    debugPrint('Firebase init failed: $e');
    debugPrint('$st');
    debugPrint('See docs/FIREBASE.md');
  }
}
