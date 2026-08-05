import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';

/// Setup is for Firebase Auth first-admin bootstrap only.
/// With local admin auth, visitors are sent to the login form.
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
                    'Create the owner admin in Firebase Console '
                    '(Authentication → Users + Firestore admins/{uid}), '
                    'then sign in. See docs/FIREBASE.md.',
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
