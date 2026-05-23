import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/router/locale_provider.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialise Supabase before anything accesses the client.
  await SupabaseConfig.initialize();

  runApp(
    // 2. ProviderScope — outermost widget, required by Riverpod.
    const ProviderScope(
      child: SoukConnectApp(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Root app widget
// ─────────────────────────────────────────────────────────────────────────────

class SoukConnectApp extends ConsumerWidget {
  const SoukConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 3. Watch the persisted locale. Falls back to French while loading.
    final locale = ref.watch(localeProvider).valueOrNull ?? const Locale('fr');
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final router = ref.watch(appRouterProvider);

    return SizerInit(
      child: MaterialApp.router(
        // ── Identity ───────────────────────────────────────────────────────
        title: 'SoukConnect',
        debugShowCheckedModeBanner: false,

        // ── Routing ────────────────────────────────────────────────────────
        routerConfig: router,

        // ── Localization ───────────────────────────────────────────────────
        locale: locale,
        supportedLocales: appSupportedLocales, // [fr, ar] from locale_provider
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocale, supportedLocales) {
          if (deviceLocale == null) return const Locale('fr');
          for (final supported in supportedLocales) {
            if (supported.languageCode == deviceLocale.languageCode) {
              return supported;
            }
          }
          return const Locale('fr'); // default fallback
        },

        // ── Theme ──────────────────────────────────────────────────────────
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
      ),
    );
  }
}
