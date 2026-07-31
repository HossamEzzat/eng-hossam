/// Single owner-admin credentials for static hosting (GitHub Pages).
///
/// There is exactly **one** admin account: Eng. Hossam.
/// No signup, no multi-admin, no public credential display.
///
/// Change email/password only in this file. Never show them in the UI.
/// Replace [LocalDevAdminAuthRepository] with a real backend later.
class AdminAuthConfig {
  AdminAuthConfig._();

  /// The only admin login email (Eng. Hossam).
  static const String adminEmail = 'hossamezzat199@gmail.com';

  /// The only admin password — keep private; edit here to rotate.
  static const String adminPassword = 'HossamAdmin!2026';

  /// Session key after a successful login (bumped to invalidate old demos).
  static const String sessionStorageKey = 'eng_hossam_owner_admin_v2';
}
