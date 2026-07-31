import 'package:flutter/foundation.dart';
import 'package:lumina/core/config/admin_auth_config.dart';
import 'package:lumina/features/admin/auth/admin_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single-owner credential check against [AdminAuthConfig].
///
/// Only Eng. Hossam's configured email + password can authenticate.
/// Suitable for GitHub Pages until a real backend is wired.
/// UI must never read [AdminAuthConfig] — only this repository may.
class LocalDevAdminAuthRepository implements LoginRepository {
  LocalDevAdminAuthRepository();

  bool _isOwner(String email) =>
      email.trim().toLowerCase() ==
      AdminAuthConfig.adminEmail.trim().toLowerCase();

  @override
  Future<AdminSession?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(AdminAuthConfig.sessionStorageKey);
      if (email == null || email.isEmpty || !_isOwner(email)) {
        await prefs.remove(AdminAuthConfig.sessionStorageKey);
        return null;
      }
      return AdminSession(email: email);
    } catch (e) {
      debugPrint('LocalDevAdminAuthRepository.restoreSession: $e');
      return null;
    }
  }

  @override
  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    final mail = email.trim().toLowerCase();
    final pass = password;

    if (mail.isEmpty || pass.isEmpty) {
      return AdminAuthResult.fail('Invalid email or password.');
    }

    // Exactly one admin account — no other emails can sign in.
    final okOwner = _isOwner(mail);
    final okPass = pass == AdminAuthConfig.adminPassword;

    if (!okOwner || !okPass) {
      return AdminAuthResult.fail('Invalid email or password.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AdminAuthConfig.sessionStorageKey, mail);
    return AdminAuthResult.ok(email: mail);
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AdminAuthConfig.sessionStorageKey);
  }
}
