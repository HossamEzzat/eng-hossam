import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/core/extensions/context_extensions.dart';
import 'package:lumina/core/extensions/l10n_extensions.dart';
import 'package:lumina/core/utils/responsive.dart';
import 'package:lumina/shared/widgets/gradient_button.dart';
import 'package:lumina/theme/app_colors.dart';
import 'package:lumina/theme/locale_provider.dart';

class SiteShell extends ConsumerWidget {
  const SiteShell({super.key, required this.child, this.showFooter = true});

  final Widget child;
  final bool showFooter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final path = GoRouterState.of(context).uri.path;
    // Use drawer until desktop to avoid cramped / overflowing link rows.
    final useDrawer = MediaQuery.sizeOf(context).width < Breakpoints.desktop;
    final nav = [
      (l10n.navHome, '/'),
      (l10n.navAbout, '/about'),
      (l10n.navCourse, '/session'),
      (l10n.navRegister, '/register'),
      (l10n.navCertificate, '/certificate'),
      (l10n.trackJourney, '/journey'),
      (l10n.navReviews, '/reviews'),
      (l10n.navFaq, '/faq'),
      (l10n.navContact, '/contact'),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: useDrawer ? _Drawer(path: path, nav: nav) : null,
      body: Column(
        children: [
          _Nav(path: path, useDrawer: useDrawer, nav: nav),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: child,
                  ),
                ),
                if (showFooter)
                  SliverToBoxAdapter(child: _Footer(nav: nav)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Nav extends ConsumerWidget {
  const _Nav({
    required this.path,
    required this.useDrawer,
    required this.nav,
  });

  final String path;
  final bool useDrawer;
  final List<(String, String)> nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final compact = MediaQuery.sizeOf(context).width < Breakpoints.desktop;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: AppConstants.navHeight,
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 24),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            children: [
              if (useDrawer)
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Flexible(
                child: InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primarySoft,
                          ),
                        ),
                        if (!compact)
                          Text(
                            l10n.brandRole,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!useDrawer) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final item in nav)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: TextButton(
                              onPressed: () => context.go(item.$2),
                              child: Text(
                                item.$1,
                                style: TextStyle(
                                  fontWeight: path == item.$2
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: path == item.$2
                                      ? AppColors.primarySoft
                                      : AppColors.textSoft,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GradientButton(
                  label: l10n.ctaReserve,
                  height: 44,
                  onPressed: () => context.go('/register'),
                ),
                const SizedBox(width: 6),
              ] else
                const Spacer(),
              TextButton(
                onPressed: () => ref.read(localeProvider.notifier).toggle(),
                child: Text(
                  l10n.language,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Drawer extends StatelessWidget {
  const _Drawer({required this.path, required this.nav});
  final String path;
  final List<(String, String)> nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.brandName,
              style: context.textTheme.headlineSmall?.copyWith(
                color: AppColors.primarySoft,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(l10n.footerTagline, style: context.textTheme.bodyMedium),
            const SizedBox(height: 20),
            for (final item in nav)
              ListTile(
                selected: path == item.$2,
                title: Text(item.$1),
                onTap: () {
                  Navigator.pop(context);
                  context.go(item.$2);
                },
              ),
            const Divider(),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/register');
              },
              child: Text(l10n.ctaReserveNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.nav});
  final List<(String, String)> nav;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pad = Responsive.value(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 24.0,
    );
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 48),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: Column(
            children: [
              Text(
                l10n.brandName,
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.footerTagline,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final item in nav)
                    TextButton(
                      onPressed: () => context.go(item.$2),
                      child: Text(item.$1),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.go('/admin/login'),
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                label: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'دخول الإدارة'
                      : 'Admin Login',
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© ${DateTime.now().year} ${AppConstants.instructorFullNameEn}',
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
