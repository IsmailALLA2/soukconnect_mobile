import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage
// Shown while authNotifierProvider resolves the initial session.
// GoRouter will navigate away once the auth state is known.
// ─────────────────────────────────────────────────────────────────────────────

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    // White status bar icons on the green background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Logo bounces in with elastic scale
    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    // Logo + name fade in together
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Tagline + dots fade in after logo settles
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,   // deep green
              AppColors.success,   // mid green
              AppColors.primaryLight, // lighter accent
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Logo ──────────────────────────────────────────────
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowDark,
                                blurRadius: 28.r,
                                offset: Offset(0, 10.h),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: AppColors.white,
                            size: 44.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // ── App name ──────────────────────────────────────────
                    FadeTransition(
                      opacity: _logoFade,
                      child: Text(
                        'SoukConnect',
                        style: AppTextStyles.headlineLarge(
                          color: AppColors.white,
                        ).copyWith(letterSpacing: 0.5),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    // ── Tagline ───────────────────────────────────────────
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        'Le marché de gros connecté',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.white.withValues(alpha: 0.72),
                        ).copyWith(letterSpacing: 0.3),
                      ),
                    ),
                    SizedBox(height: 72.h),

                    // ── Pulsing dots ──────────────────────────────────────
                    FadeTransition(
                      opacity: _taglineFade,
                      child: const _PulsingDots(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three pulsing loading dots — wave pattern
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot is shifted 1/3 of the cycle
            final phase = i / 3.0;
            final t = (_ctrl.value + phase) % 1.0;
            final sinVal = math.sin(t * 2 * math.pi);
            final opacity = 0.3 + 0.7 * ((sinVal + 1) / 2);
            final size = 7.0 + 3.0 * ((sinVal + 1) / 2);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Container(
                width: size.w,
                height: size.w,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
