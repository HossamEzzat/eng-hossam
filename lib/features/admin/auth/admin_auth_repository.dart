/// Result of an authentication attempt.
class AdminAuthResult {
  const AdminAuthResult._({
    required this.success,
    this.email,
    this.errorMessage,
  });

  factory AdminAuthResult.ok({required String email}) => AdminAuthResult._(
        success: true,
        email: email,
      );

  factory AdminAuthResult.fail(String message) => AdminAuthResult._(
        success: false,
        errorMessage: message,
      );

  final bool success;
  final String? email;
  final String? errorMessage;
}

/// Snapshot of the current admin session (if any).
class AdminSession {
  const AdminSession({required this.email});

  final String email;
}

/// Authentication backend contract.
///
/// Swap implementations without touching UI or [AuthService]:
/// - [LocalDevAdminAuthRepository] — config email/password (GitHub Pages)
/// - [FirebaseAdminAuthRepository] — Firebase Auth + admins/{uid}
/// - Future: Supabase / Appwrite / Node / ASP.NET API
abstract class LoginRepository {
  /// Restore a previously established session, if still valid.
  Future<AdminSession?> restoreSession();

  /// Authenticate with email + password.
  Future<AdminAuthResult> login({
    required String email,
    required String password,
  });

  /// Clear the current session.
  Future<void> logout();
}
