import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/animations/page_transitions.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/features/about/presentation/pages/about_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_certificate_preview_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_exports_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_login_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_reviews_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_sessions_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_setup_page.dart';
import 'package:lumina/features/admin/presentation/pages/admin_students_page.dart';
import 'package:lumina/features/admin/presentation/providers/admin_providers.dart';
import 'package:lumina/features/admin/presentation/shell/admin_shell.dart';
import 'package:lumina/features/certificate/presentation/pages/certificate_page.dart';
import 'package:lumina/features/contact/presentation/pages/contact_page.dart';
import 'package:lumina/features/faq/presentation/pages/faq_page.dart';
import 'package:lumina/features/home/presentation/pages/home_page.dart';
import 'package:lumina/features/journey/presentation/pages/journey_page.dart';
import 'package:lumina/features/register/presentation/pages/register_page.dart';
import 'package:lumina/features/reviews/presentation/pages/reviews_page.dart';
import 'package:lumina/features/reviews/presentation/pages/thank_you_page.dart';
import 'package:lumina/features/session/presentation/pages/session_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(adminAuthProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: auth,
    redirect: (context, state) {
      final path = state.uri.path;
      final loggingIn = path == '/admin/login';
      final settingUp = path == '/admin/setup';
      final isAdminRoute =
          path == '/admin' || path.startsWith('/admin/');

      if (!isAdminRoute) return null;

      // Never expose admin UI while session is loading.
      if (auth.isRestoring) {
        return loggingIn ? null : '/admin/login';
      }

      // Setup is Firebase-only bootstrap; local/dev uses login only.
      if (settingUp && !AppConstants.useFirebase) {
        return '/admin/login';
      }

      if (!auth.isAuthenticated) {
        if (loggingIn) return null;
        if (settingUp && AppConstants.useFirebase) return null;
        return '/admin/login';
      }

      // Authenticated admins leave the login screen.
      if (loggingIn || settingUp) {
        return '/admin';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const AboutPage(),
        ),
      ),
      GoRoute(
        path: '/session',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const SessionPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) {
          final session = state.uri.queryParameters['session'];
          return buildFadeSlidePage(
            state: state,
            child: RegisterPage(preselectedSessionId: session),
          );
        },
      ),
      GoRoute(
        path: '/certificate',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const CertificatePage(),
        ),
      ),
      GoRoute(
        path: '/journey',
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters['q'];
          return buildFadeSlidePage(
            state: state,
            child: JourneyPage(initialQuery: q),
          );
        },
      ),
      GoRoute(
        path: '/reviews',
        pageBuilder: (context, state) {
          final reg = state.uri.queryParameters['reg'];
          final mobile = state.uri.queryParameters['mobile'];
          return buildFadeSlidePage(
            state: state,
            child: ReviewsPage(registrationId: reg, mobile: mobile),
          );
        },
      ),
      GoRoute(
        path: '/thank-you',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const ThankYouPage(),
        ),
      ),
      GoRoute(
        path: '/faq',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const FaqPage(),
        ),
      ),
      GoRoute(
        path: '/contact',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const ContactPage(),
        ),
      ),
      GoRoute(
        path: '/admin/setup',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const AdminSetupPage(),
        ),
      ),
      GoRoute(
        path: '/admin/login',
        pageBuilder: (context, state) => buildFadeSlidePage(
          state: state,
          child: const AdminLoginPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminDashboardPage(),
            ),
          ),
          GoRoute(
            path: '/admin/students',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminStudentsPage(),
            ),
          ),
          GoRoute(
            path: '/admin/sessions',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminSessionsPage(),
            ),
          ),
          GoRoute(
            path: '/admin/certificates',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminCertificatePreviewPage(),
            ),
          ),
          GoRoute(
            path: '/admin/reviews',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminReviewsPage(),
            ),
          ),
          GoRoute(
            path: '/admin/exports',
            pageBuilder: (context, state) => buildFadeSlidePage(
              state: state,
              child: const AdminExportsPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
