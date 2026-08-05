import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumina/core/constants/app_constants.dart';
import 'package:lumina/data/repositories/session_repository.dart';
import 'package:lumina/data/services/session_store.dart';
import 'package:lumina/firebase/firebase_bootstrap.dart';
import 'package:lumina/l10n/app_localizations.dart';
import 'package:lumina/router/app_router.dart';
import 'package:lumina/theme/app_theme.dart';
import 'package:lumina/theme/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  GoogleFonts.config.allowRuntimeFetching = true;
  // Never leave Safari on a blank page if IndexedDB / Firebase hangs.
  await bootstrapFirebase().timeout(
    const Duration(seconds: 6),
    onTimeout: () {},
  );
  // Load registrations/reviews from browser localStorage before UI paints,
  // so admin sees real students (not only the old in-memory demo seeds).
  await SessionStore.instance.hydrate().timeout(
    const Duration(seconds: 4),
    onTimeout: () {},
  );
  // When Firebase is on, overwrite local cache with Firestore (cross-device).
  // Timeout so a slow/blocked Firestore never leaves a blank first paint.
  if (AppConstants.useFirebase) {
    await SessionRepository()
        .syncFromRemote()
        .timeout(const Duration(seconds: 8), onTimeout: () {});
  }
  runApp(const ProviderScope(child: EngHossamApp()));
}

class EngHossamApp extends ConsumerWidget {
  const EngHossamApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';

    return MaterialApp.router(
      title: isAr
          ? '${AppConstants.instructorNameAr} · دورة البرمجة'
          : '${AppConstants.instructorNameEn} · Programming Course',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark.copyWith(
        textTheme: AppTypography.forLocale(locale),
      ),
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}
