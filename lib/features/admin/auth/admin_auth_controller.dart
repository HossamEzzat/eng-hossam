import 'package:flutter/foundation.dart';
import 'package:lumina/features/admin/auth/admin_auth_repository.dart';

/// UI-facing auth service. Depends only on [LoginRepository].
///
/// Never embeds credentials or backend SDKs — swap the repository to change
/// Firebase / Supabase / API backends without touching widgets.
class AuthService extends ChangeNotifier {
  AuthService(this._repository);

  final LoginRepository _repository;

  bool _authenticated = false;
  bool _restoring = true;
  String? _error;
  String? _email;

  bool get isAuthenticated => _authenticated;
  bool get isRestoring => _restoring;
  String? get error => _error;
  String? get email => _email;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<void> restore() async {
    _restoring = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _repository.restoreSession();
      if (session != null && session.email.isNotEmpty) {
        _authenticated = true;
        _email = session.email;
      } else {
        _authenticated = false;
        _email = null;
      }
    } catch (e) {
      debugPrint('AuthService.restore: $e');
      _authenticated = false;
      _email = null;
    } finally {
      _restoring = false;
      notifyListeners();
    }
  }

  /// Returns true only after the repository validates email + password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _error = null;
    notifyListeners();

    final result = await _repository.login(
      email: email,
      password: password,
    );

    if (!result.success) {
      _authenticated = false;
      _email = null;
      _error = result.errorMessage ?? 'Invalid email or password.';
      notifyListeners();
      return false;
    }

    _authenticated = true;
    _email = result.email;
    _error = null;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _repository.logout();
    _authenticated = false;
    _email = null;
    _error = null;
    notifyListeners();
  }
}
