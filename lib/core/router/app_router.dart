import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/detaillant/presentation/pages/detaillant_shell.dart';
import '../../features/detaillant/presentation/pages/my_orders_page.dart';
import '../../features/detaillant/presentation/pages/nearby_stores_page.dart';
import '../../features/grossiste/presentation/pages/grossiste_shell.dart';
import '../../features/grossiste/presentation/pages/incoming_orders_page.dart';
import '../../features/grossiste/presentation/pages/my_products_page.dart';
import '../../features/grossiste/presentation/pages/my_store_page.dart';
import '../../shared/widgets/profile_page.dart';

part 'app_router.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Named route paths — use these constants everywhere, never raw strings
// ─────────────────────────────────────────────────────────────────────────────

abstract class AppRoutes {
  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';

  // Détaillant shell tabs
  static const detaillantStores = '/detaillant/stores';
  static const detaillantOrders = '/detaillant/orders';
  static const detaillantProfile = '/detaillant/profile';

  // Grossiste shell tabs
  static const grossisteStore = '/grossiste/store';
  static const grossisteProducts = '/grossiste/products';
  static const grossisteOrders = '/grossiste/orders';
  static const grossisteProfile = '/grossiste/profile';
}

// ─────────────────────────────────────────────────────────────────────────────
// Router provider
// @Riverpod(keepAlive: true) — GoRouter must never be recreated mid-session
// ─────────────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  // RouterRefreshNotifier wakes up GoRouter whenever auth state changes,
  // triggering the redirect callback below.
  final refreshNotifier = RouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false, // set true while developing
    refreshListenable: refreshNotifier,

    // ── Global redirect ─────────────────────────────────────────────────────
    redirect: (context, state) async {
      // authNotifierProvider holds UserEntity? — null means not logged in.
      final authState = ref.read(authNotifierProvider);
      final userEntity = authState.valueOrNull;
      final isLoggedIn = userEntity != null;

      final onAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Still loading → stay on splash
      if (authState.isLoading) return AppRoutes.splash;

      // Not logged in → always go to login
      if (!isLoggedIn) {
        return onAuthPage ? null : AppRoutes.login;
      }

      // Already logged in but on splash / auth pages → route by role (typed enum)
      if (state.matchedLocation == AppRoutes.splash || onAuthPage) {
        if (userEntity.isGrossiste) return AppRoutes.grossisteStore;
        return AppRoutes.detaillantStores; // detaillant or admin default
      }

      return null; // no redirect needed
    },

    // ── Route tree ──────────────────────────────────────────────────────────
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ── Détaillant shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            DetaillantShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.detaillantStores,
            builder: (context, state) => const NearbyStoresPage(),
          ),
          GoRoute(
            path: AppRoutes.detaillantOrders,
            builder: (context, state) => const MyOrdersPage(),
          ),
          GoRoute(
            path: AppRoutes.detaillantProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // ── Grossiste shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            GrossisteShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.grossisteStore,
            builder: (context, state) => const MyStorePage(),
          ),
          GoRoute(
            path: AppRoutes.grossisteProducts,
            builder: (context, state) => const MyProductsPage(),
          ),
          GoRoute(
            path: AppRoutes.grossisteOrders,
            builder: (context, state) => const IncomingOrdersPage(),
          ),
          GoRoute(
            path: AppRoutes.grossisteProfile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],

    // ── 404 page ─────────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page introuvable',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.splash),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
}
