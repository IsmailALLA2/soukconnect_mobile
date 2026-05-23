import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// App Router
//
// Placeholder routes — replace with real feature pages as they are built.
// Route names are defined as constants to avoid magic strings.
// ─────────────────────────────────────────────────────────────────────────────

/// Named route constants.
abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const detaillantHome = '/detaillant';
  static const grossisteHome = '/grossiste';
  static const settings = '/settings';
}

/// The top-level [GoRouter] instance used by [MaterialApp.router].
///
/// Riverpod integration: expose this via a [Provider] once authentication
/// state needs to influence redirects. For now it is a plain singleton.
final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true, // set to false in production

  // ── Routes ────────────────────────────────────────────────────────────────
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const _SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(label: 'Login'),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) =>
          const _PlaceholderScreen(label: 'Register'),
    ),
    GoRoute(
      path: AppRoutes.detaillantHome,
      name: 'detaillant',
      builder: (context, state) =>
          const _PlaceholderScreen(label: 'Détaillant Home'),
    ),
    GoRoute(
      path: AppRoutes.grossisteHome,
      name: 'grossiste',
      builder: (context, state) =>
          const _PlaceholderScreen(label: 'Grossiste Home'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) =>
          const _PlaceholderScreen(label: 'Settings'),
    ),
  ],

  // ── Error page ────────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page introuvable\n${state.error}',
        textAlign: TextAlign.center,
      ),
    ),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Temporary placeholder screens — replace with real pages
// ─────────────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Check auth state and redirect appropriately.
    // For now, navigate to login after a short delay.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A6B3C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'SoukConnect',
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(
        child: Text(
          '$label\n(coming soon)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
