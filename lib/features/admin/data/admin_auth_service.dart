import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin authentication with route-guard support.
///
/// **Demo mode** (`useFirebase == false`):
///   Email: [AppConstants.adminEmail]
///   Password: [AppConstants.adminPassword]
///
/// **Firebase mode** (`useFirebase == true`):
///   Firebase Auth (email/password) + Firestore `admins/{uid}` role check.
///   First admin is created via [/admin/setup] when no admin exists yet.
class AdminAuthService extends ChangeNotifier {
  AdminAuthService();

  static const _prefsKey = 'hossam_admin';
  static const _setupKey = 'hossam_admin_setup_done';

  bool _authenticated = false;
  bool _restoring = true;
  bool _setupDone = true;
  bool _needsFirebaseBootstrap = false;
  bool _accessDenied = false;
  String? _error;
  String? _email;

  bool get isAuthenticated => _authenticated;
  bool get isRestoring => _restoring;

  /// Demo: first-run prefs. Firebase: no admin docs / bootstrap yet.
  bool get needsSetup => AppConstants.useFirebase
      ? _needsFirebaseBootstrap
      : !_setupDone;

  bool get accessDenied => _accessDenied;
  String? get error => _error;
  String? get email => _email;
  bool get usesFirebaseAuth => AppConstants.useFirebase;

  void clearAccessDenied() {
    if (!_accessDenied) return;
    _accessDenied = false;
    notifyListeners();
  }

  Future<void> restore() async {
    _restoring = true;
    notifyListeners();
    try {
      if (AppConstants.useFirebase) {
        _needsFirebaseBootstrap = await _isBootstrapOpen();
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (await _isAdminUid(user.uid)) {
            _authenticated = true;
            _email = user.email;
            _needsFirebaseBootstrap = false;
          } else {
            await FirebaseAuth.instance.signOut();
            _authenticated = false;
          }
        } else {
          _authenticated = false;
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        _setupDone = prefs.getBool(_setupKey) ?? false;
        _authenticated = prefs.getBool(_prefsKey) ?? false;
        if (_authenticated) _email = AppConstants.adminEmail;
      }
    } catch (e) {
      debugPrint('AdminAuth restore failed: $e');
      _authenticated = false;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  /// Demo-mode first-run confirmation.
  Future<bool> completeSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupKey, true);
    _setupDone = true;
    _error = null;
    notifyListeners();
    return true;
  }

  /// Creates the first Firebase Auth admin + Firestore `admins/{uid}` doc.
  Future<bool> createFirstAdmin({
    required String email,
    required String password,
    required String name,
  }) async {
    _error = null;
    _accessDenied = false;
    if (!AppConstants.useFirebase) {
      return completeSetup();
    }

    final mail = email.trim().toLowerCase();
    if (mail.isEmpty || password.length < 6 || name.trim().isEmpty) {
      _error = 'Name, email, and a password (6+ chars) are required';
      notifyListeners();
      return false;
    }

    try {
      if (!await _isBootstrapOpen()) {
        _error = 'An admin already exists. Sign in instead.';
        notifyListeners();
        return false;
      }

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        _error = 'Could not create admin account';
        notifyListeners();
        return false;
      }

      await user.updateDisplayName(name.trim());

      final batch = FirebaseFirestore.instance.batch();
      batch.set(
        FirebaseFirestore.instance.collection('admins').doc(user.uid),
        {
          'uid': user.uid,
          'email': mail,
          'name': name.trim(),
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
        },
      );
      batch.set(
        FirebaseFirestore.instance.collection('config').doc('bootstrap'),
        {
          'adminCreated': true,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': user.uid,
        },
      );
      await batch.commit();

      _needsFirebaseBootstrap = false;
      _authenticated = true;
      _email = mail;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Could not create admin';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String password,
    String? email,
  }) async {
    _error = null;
    _accessDenied = false;
    try {
      if (AppConstants.useFirebase) {
        final mail = email?.trim() ?? '';
        if (mail.isEmpty) {
          _error = 'Email is required';
          notifyListeners();
          return false;
        }
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: mail,
          password: password,
        );
        final uid = cred.user?.uid;
        if (uid == null || !await _isAdminUid(uid)) {
          await FirebaseAuth.instance.signOut();
          _error = 'Access Denied — this account is not an admin.';
          _accessDenied = true;
          _authenticated = false;
          notifyListeners();
          return false;
        }
        _authenticated = true;
        _email = mail;
        _needsFirebaseBootstrap = false;
        notifyListeners();
        return true;
      }

      final mail = (email ?? '').trim().toLowerCase();
      if (mail.isNotEmpty && mail != AppConstants.adminEmail.toLowerCase()) {
        _error = 'Access Denied — unknown admin email.';
        _accessDenied = true;
        notifyListeners();
        return false;
      }
      if (password.trim() != AppConstants.adminPassword) {
        _error = 'Wrong password';
        notifyListeners();
        return false;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
      await prefs.setBool(_setupKey, true);
      _setupDone = true;
      _authenticated = true;
      _email = AppConstants.adminEmail;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Authentication failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (AppConstants.useFirebase) {
      await FirebaseAuth.instance.signOut();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, false);
    }
    _authenticated = false;
    _email = null;
    _accessDenied = false;
    notifyListeners();
  }

  Future<bool> _isAdminUid(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('admins').doc(uid).get();
    if (!doc.exists) return false;
    final role = doc.data()?['role'];
    return role == null || role == 'admin' || role == 'owner' || role == 'editor';
  }

  /// True when first-admin bootstrap is still allowed.
  Future<bool> _isBootstrapOpen() async {
    try {
      final boot = await FirebaseFirestore.instance
          .collection('config')
          .doc('bootstrap')
          .get();
      if (boot.exists && boot.data()?['adminCreated'] == true) {
        return false;
      }
      return true;
    } catch (_) {
      // If rules block the read, assume bootstrap may still be needed.
      return true;
    }
  }
}
