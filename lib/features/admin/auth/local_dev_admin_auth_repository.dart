import 'package:lumina/core/config/admin_auth_config.dart';
import 'package:lumina/features/admin/auth/admin_auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Temporary credential check against [AdminAuthConfig].
///
/// Suitable for static hosting (GitHub Pages) until a real backend is wired.
/// UI must never read [AdminAuthConfig] — only this repository may.
class LocalDevAdminAuthRepository implements LoginRepository {
  LocalDevAdminAuthRepository();

  @override
  Future<AdminSession?> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(AdminAuthConfig.sessionStorageKey);
      if (email == null || email.isEmpty) return null;
      // Only restore if it still matches the configured admin.
      if (email.toLowerCase() != AdminAuthConfig.adminEmail.toLowerCase()) {
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

    final okEmail =
        mail == AdminAuthConfig.adminEmail.trim().toLowerCase();
    final okPass = pass == AdminAuthConfig.adminPassword;

    if (!okEmail || !okPass) {
      // Constant message — do not reveal which field failed.
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
