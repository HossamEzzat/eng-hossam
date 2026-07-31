import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/theme/app_colors.dart';

class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  static const _nav = [
    (Icons.dashboard_outlined, 'Dashboard', '/admin'),
    (Icons.people_outline, 'Students', '/admin/students'),
    (Icons.event_outlined, 'Sessions', '/admin/sessions'),
    (Icons.workspace_premium_outlined, 'Certificates', '/admin/certificates'),
    (Icons.reviews_outlined, 'Reviews', '/admin/reviews'),
    (Icons.download_outlined, 'Exports', '/admin/exports'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(adminAuthProvider);

    // Defense in depth: never render admin chrome without a session.
    if (auth.isRestoring || !auth.isAuthenticated) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final path = GoRouterState.of(context).uri.path;
    final wide = MediaQuery.sizeOf(context).width >= 1000;
    final selected = _nav.indexWhere((e) {
      if (e.$3 == '/admin') return path == '/admin';
      return path.startsWith(e.$3);
    }).clamp(0, _nav.length - 1);

    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: wide
          ? null
          : Drawer(
              backgroundColor: AppColors.surface,
              child: SafeArea(
                child: _SideNav(
                  selected: selected,
                  onSelect: (i) {
                    Navigator.pop(context);
                    context.go(_nav[i].$3);
                  },
                  onLogout: () async {
                    await ref.read(adminAuthProvider).logout();
                    if (context.mounted) context.go('/');
                  },
                ),
              ),
            ),
      body: Row(
        children: [
          if (wide)
            SizedBox(
              width: 240,
              child: Material(
                color: AppColors.surface,
                child: _SideNav(
                  selected: selected,
                  onSelect: (i) => context.go(_nav[i].$3),
                  onLogout: () async {
                    await ref.read(adminAuthProvider).logout();
                    if (context.mounted) context.go('/');
                  },
                ),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                _TopBar(wide: wide),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.wide});
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          if (!wide)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Text(
              'Admin · Programming with Eng. Hossam',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
            ),
          ),
          if (MediaQuery.sizeOf(context).width < 420)
            IconButton(
              tooltip: 'View site',
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public_outlined, size: 20),
            )
          else
            TextButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.public_outlined, size: 18),
              label: const Text('View site'),
            ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selected,
    required this.onSelect,
    required this.onLogout,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'ENG. HOSSAM',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Control Center',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < AdminShell._nav.length; i++)
          _NavTile(
            icon: AdminShell._nav[i].$1,
            label: AdminShell._nav[i].$2,
            selected: selected == i,
            onTap: () => onSelect(i),
          ),
        const Spacer(),
        const Divider(height: 1),
        Material(
          color: Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout'),
            hoverColor: AppColors.error.withValues(alpha: 0.08),
            onTap: onLogout,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          selected: selected,
          hoverColor: AppColors.primary.withValues(alpha: 0.08),
          leading: Icon(
            icon,
            color: selected ? AppColors.primary : AppColors.textSoft,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.text : AppColors.textSoft,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
