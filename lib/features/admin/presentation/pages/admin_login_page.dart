import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _loading = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(
      text: AppConstants.useFirebase ? '' : AppConstants.adminEmail,
    );
    _password = TextEditingController(
      text: AppConstants.useFirebase ? '' : AppConstants.adminPassword,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final auth = ref.read(adminAuthProvider);
    final ok = await auth.login(
      password: _password.text,
      email: _email.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/admin');
      return;
    }

    if (auth.accessDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Access Denied — admins only. Returning home.'),
          backgroundColor: AppColors.error,
        ),
      );
      auth.clearAccessDenied();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(adminAuthProvider);
    if (auth.isRestoring) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/admin');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Admin Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.text,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppConstants.useFirebase
                            ? 'Firebase Authentication · Admins only'
                            : 'URL: /admin/login  ·  Protected admin area',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSoft,
                            ),
                      ),
                      const SizedBox(height: 20),
                      if (!AppConstants.useFirebase) ...[
                        _credentialsCard(context),
                        const SizedBox(height: 20),
                      ],
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
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                      if (auth.error != null && !auth.accessDenied) ...[
                        const SizedBox(height: 12),
                        Text(
                          auth.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ],
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Enter dashboard',
                        expand: true,
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                      if (auth.needsSetup) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/admin/setup'),
                          child: const Text('Create first admin account'),
                        ),
                      ],
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to website'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _credentialsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Demo admin credentials (first account ready)',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          _credRow(context, 'Email', AppConstants.adminEmail),
          const SizedBox(height: 6),
          _credRow(context, 'Password', AppConstants.adminPassword),
          const SizedBox(height: 8),
          const Text(
            'No setup needed — this is the default admin for local/demo mode.',
            style: TextStyle(color: AppColors.textSoft, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _credRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label copied')),
            );
          },
          icon: const Icon(Icons.copy_rounded, size: 18),
        ),
      ],
    );
  }
}
