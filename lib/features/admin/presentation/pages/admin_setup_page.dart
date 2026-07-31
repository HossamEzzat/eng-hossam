import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Setup is unused for the single-owner local admin.
/// Always send visitors to the login form.
class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Admin access',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This site has a single owner-admin account. '
                    'There is no public signup. Sign in with your admin email and password.',
                    style: TextStyle(color: AppColors.textSoft, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Go to Admin Login',
                    expand: true,
                    onPressed: () => context.go('/admin/login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
