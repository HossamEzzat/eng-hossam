import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/fade_in_view.dart';
import 'package:lumina/shared/widgets/glass_card.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/shared/widgets/section_header.dart';
import 'package:lumina/theme/app_colors.dart';

class InstructorTeaserSection extends StatelessWidget {
  const InstructorTeaserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = Responsive.isWide(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.bg,
            Color(0xFF0F172A),
            AppColors.bg,
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 48 : 24,
          vertical: 88,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxContentWidth,
            ),
            child: FadeInView(
              child: GlassCard(
                padding: EdgeInsets.all(wide ? 40 : 24),
                glow: true,
                child: wide
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _Photo(),
                          SizedBox(width: 40),
                          Expanded(child: _Copy()),
                        ],
                      )
                    : const Column(
                        children: [
                          _Photo(),
                          SizedBox(height: 28),
                          _Copy(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 48;
        final w = 220.0.clamp(140.0, maxW).toDouble();
        final h = w * (260 / 220);
        return Container(
          width: w,
          height: h,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Image.asset(
              'assets/images/instructor.jpg',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 500.ms).scale(
          begin: const Offset(0.96, 0.96),
          curve: Curves.easeOutCubic,
        );
  }
}

class _Copy extends StatelessWidget {
  const _Copy();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          animate: false,
          eyebrow: l10n.navAbout,
          headline: l10n.aboutTitle,
          subtitle: null,
          maxWidth: 560,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.brandName,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.brandRole,
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSoft,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.aboutSubtitle,
          style: context.textTheme.bodyLarge?.copyWith(
            height: 1.75,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final company in AppConstants.companies)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: AppColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  company.$1,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${AppConstants.academies.take(3).join(' · ')} · ${l10n.awardsTitle}',
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        GradientButton(
          label: l10n.aboutCta,
          icon: Icons.arrow_forward_rounded,
          variant: GradientButtonVariant.secondary,
          onPressed: () => context.go('/about'),
        ),
      ],
    );
  }
}
