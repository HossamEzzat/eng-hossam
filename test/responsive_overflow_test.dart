import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/features/about/presentation/pages/about_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_login_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_sessions_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_students_page.dart';
import 'package:lumina/features/admin/presentation/shell/admin_shell.dart';
import 'package:lumina/features/contact/presentation/pages/contact_page.dart';
import 'package:lumina/features/faq/presentation/pages/faq_page.dart';
import 'package:lumina/features/home/presentation/pages/home_page.dart';
import 'package:lumina/features/journey/presentation/pages/journey_page.dart';
import 'package:lumina/features/register/presentation/pages/register_page.dart';
import 'package:lumina/features/reviews/presentation/pages/reviews_page.dart';
import 'package:lumina/features/session/presentation/pages/session_page.dart';
import 'package:lumina/l10n/app_localizations.dart';
import 'package:lumina/theme/app_theme.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  VisibilityDetectorController.instance.updateInterval = Duration.zero;

  const sizes = <Size>[
    Size(320, 720),
    Size(768, 1024),
    Size(1440, 900),
  ];

  final pages = <String, Widget Function()>{
    'home': HomePage.new,
    'about': AboutPage.new,
    'session': SessionPage.new,
    'register': RegisterPage.new,
    'journey': JourneyPage.new,
    'reviews': ReviewsPage.new,
    'faq': FaqPage.new,
    'contact': ContactPage.new,
    'admin-login': AdminLoginPage.new,
    'admin-dashboard': () => const AdminShell(child: AdminDashboardPage()),
    'admin-students': () => const AdminShell(child: AdminStudentsPage()),
    'admin-sessions': () => const AdminShell(child: AdminSessionsPage()),
  };

  for (final size in sizes) {
    for (final entry in pages.entries) {
      testWidgets(
        '${entry.key} @ ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          final overflows = <String>[];

          await tester.binding.setSurfaceSize(size);
          addTearDown(() async {
            await tester.binding.setSurfaceSize(null);
          });

          final container = ProviderContainer();
          addTearDown(container.dispose);

          final router = GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => entry.value(),
              ),
            ],
          );

          final oldOnError = FlutterError.onError;
          FlutterError.onError = (details) {
            final msg = details.exceptionAsString();
            if (msg.contains('overflowed')) {
              overflows.add('$details');
            }
          };

          try {
            await tester.pumpWidget(
              UncontrolledProviderScope(
                container: container,
                child: MaterialApp.router(
                  theme: AppTheme.dark,
                  locale: const Locale('ar'),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: router,
                ),
              ),
            );

            for (var i = 0; i < 12; i++) {
              await tester.pump(const Duration(milliseconds: 50));
            }

            // Skip gesture scrolling on admin tables (nested scroll + drawer hit tests).
            if (!entry.key.startsWith('admin-')) {
              final scrollables = find.byType(Scrollable);
              if (scrollables.evaluate().isNotEmpty) {
                try {
                  await tester.drag(scrollables.last, const Offset(0, -300));
                  for (var i = 0; i < 6; i++) {
                    await tester.pump(const Duration(milliseconds: 40));
                  }
                } catch (_) {
                  // Ignore hit-test failures from nested drawers/tables.
                }
              }
            }

            // Unmount before ProviderContainer.dispose to avoid double-dispose.
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump(const Duration(milliseconds: 100));
          } finally {
            FlutterError.onError = oldOnError;
            tester.takeException();
          }

          expect(overflows, isEmpty, reason: overflows.join('\n---\n'));
        },
      );
    }
  }
}
