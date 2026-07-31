import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Firebase-only first-admin bootstrap entry.
/// Local/dev static hosting always redirects here away to [/admin/login].
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
                    'Admin setup',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Use Admin Login with your configured credentials. '
                    'Firebase first-admin bootstrap is available only when '
                    'useFirebase is enabled.',
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
