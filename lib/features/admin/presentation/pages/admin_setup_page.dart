import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Creates the first admin account (demo confirm or Firebase Auth + Firestore).
class AdminSetupPage extends ConsumerStatefulWidget {
  const AdminSetupPage({super.key});

  @override
  ConsumerState<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends ConsumerState<AdminSetupPage> {
  final _name = TextEditingController(text: 'Eng. Hossam');
  final _email = TextEditingController(text: AppConstants.adminEmail);
  final _password = TextEditingController(text: AppConstants.adminPassword);
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final auth = ref.read(adminAuthProvider);
    final ok = AppConstants.useFirebase
        ? await auth.createFirstAdmin(
            email: _email.text,
            password: _password.text,
            name: _name.text,
          )
        : await auth.completeSetup();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      context.go(AppConstants.useFirebase ? '/admin' : '/admin/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(adminAuthProvider);
    final firebase = AppConstants.useFirebase;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    firebase
                        ? 'Create the first Admin'
                        : 'Create your Admin access',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    firebase
                        ? 'No administrator exists yet. This creates a Firebase '
                            'Auth user and an admins/{uid} Firestore document '
                            'with role = admin.'
                        : 'Demo mode uses a pre-created local admin. Confirm '
                            'below, then sign in.',
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!firebase) ...[
                    _row('URL', '/admin/login'),
                    _row('Email', AppConstants.adminEmail),
                    _row('Password', AppConstants.adminPassword),
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Continue to login',
                      expand: true,
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                  ] else ...[
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Admin email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password (min 6 characters)',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                    if (auth.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        auth.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                    const SizedBox(height: 24),
                    GradientButton(
                      label: 'Create admin & open dashboard',
                      expand: true,
                      isLoading: _loading,
                      icon: Icons.admin_panel_settings_outlined,
                      onPressed: _submit,
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/admin/login'),
                    child: const Text('Already have an account? Sign in'),
                  ),
                  TextButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Back to website'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(k, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: SelectableText(
              v,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
