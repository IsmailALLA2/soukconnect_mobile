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
import '../../features/detaillant/presentation/pages/cart_page.dart';
import '../../features/detaillant/presentation/pages/store_detail_page.dart';
import '../../features/detaillant/presentation/pages/store_map_page.dart';
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

  // Détaillant detail pages (outside shell — full screen)
  static const detaillantStoreDetail = '/detaillant/store/:storeId';

  static const detaillantCart = '/detaillant/cart';
  static const detaillantStoreMap = '/detaillant/map/:storeId';

  /// Builds a concrete store detail path from [storeId].
  static String storeDetail(String storeId) => '/detaillant/store/$storeId';

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

  // ── Minimum splash duration ──────────────────────────────────────────────
  // On cold open, authNotifierProvider can resolve before the first frame
  // renders, so the splash is never seen. This flag ensures we always show
  // the splash for at least 1.5 s (the full animation length).
  bool splashReady = false;
  Future.delayed(const Duration(milliseconds: 1500), () {
    splashReady = true;
    refreshNotifier.refresh();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false, // set true while developing
    refreshListenable: refreshNotifier,

    // ── Global redirect ─────────────────────────────────────────────────────
    redirect: (context, state) async {
      // Always hold on splash until the minimum display time has passed.
      if (!splashReady) return AppRoutes.splash;

      // authNotifierProvider holds UserEntity? — null means not logged in.
      final authState = ref.read(authNotifierProvider);

      // Still resolving initial session → show splash while we wait.
      if (authState.isLoading) return AppRoutes.splash;

      // If an error occurred (e.g. profiles table missing, network issue)
      // treat as unauthenticated and fall through to /login.
      final userEntity = authState.valueOrNull;
      final isLoggedIn = userEntity != null;

      final onAuthPage = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // Not logged in → always go to login
      if (!isLoggedIn) {
        return onAuthPage ? null : AppRoutes.login;
      }

      // Already logged in but on splash / auth pages → route by role
      if (state.matchedLocation == AppRoutes.splash || onAuthPage) {
        if (userEntity.isGrossiste) return AppRoutes.grossisteStore;
        return AppRoutes.detaillantStores; // detaillant or admin default
      }

      return null; // no redirect needed
    },

    // ── Route tree ──────────────────────────────────────────────────────────
    routes: [
      // ── Auth (fade transition) ─────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: _fadeTransition,
        ),
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
            path: AppRoutes.detaillantCart,
            builder: (context, state) => const CartPage(),
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

      // ── Détaillant detail pages (full-screen, outside shell) ───────────────
      GoRoute(
        path: AppRoutes.detaillantStoreDetail,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoreDetailPage(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: _slideFromRightTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.detaillantStoreMap,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const StoreMapPage(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: _fadeScaleTransition,
        ),
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

// ── Page transition builders ───────────────────────────────────────────────────

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideFromRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _fadeScaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      ),
      child: child,
    ),
  );
}
