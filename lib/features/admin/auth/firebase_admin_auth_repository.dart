import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/features/admin/auth/admin_auth_repository.dart';

/// Firebase Auth + Firestore `admins/{uid}` role check.
///
/// Enable by setting `AppConstants.useFirebase = true` and configuring
/// `firebase_options.dart`. UI stays unchanged.
class FirebaseAdminAuthRepository implements LoginRepository {
  FirebaseAdminAuthRepository();

  @override
  Future<AdminSession?> restoreSession() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      if (!await _isAdminUid(user.uid)) {
        await FirebaseAuth.instance.signOut();
        return null;
      }
      return AdminSession(email: user.email ?? '');
    } catch (e) {
      debugPrint('FirebaseAdminAuthRepository.restoreSession: $e');
      return null;
    }
  }

  @override
  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    final mail = email.trim();
    if (mail.isEmpty || password.isEmpty) {
      return AdminAuthResult.fail('Invalid email or password.');
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null || !await _isAdminUid(uid)) {
        await FirebaseAuth.instance.signOut();
        return AdminAuthResult.fail('Invalid email or password.');
      }
      return AdminAuthResult.ok(email: mail);
    } on FirebaseAuthException {
      return AdminAuthResult.fail('Invalid email or password.');
    } catch (e) {
      debugPrint('FirebaseAdminAuthRepository.login: $e');
      return AdminAuthResult.fail('Invalid email or password.');
    }
  }

  @override
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<bool> _isAdminUid(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    if (!doc.exists) return false;
    final role = doc.data()?['role'];
    return role == null ||
        role == 'admin' ||
        role == 'owner' ||
        role == 'editor';
  }
}
