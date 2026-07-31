/// Temporary admin credentials for static hosting (e.g. GitHub Pages).
///
/// Replace [LocalDevAdminAuthRepository] with Firebase/Supabase/API later —
/// this file is the only place to change temporary email/password.
///
/// Keep this out of public UI. Never display these values on screen.
/// Rotate after any accidental exposure on a public page.
class AdminAuthConfig {
  AdminAuthConfig._();

  /// Development / static-host temporary admin.
  static const String adminEmail = 'admin@enghossam.app';

  /// Rotated after credentials were previously shown on the login UI.
  static const String adminPassword = 'HossamAdmin!2026';

  /// Session key for local persistence after a successful login.
  static const String sessionStorageKey = 'eng_hossam_admin_session_v1';
}
