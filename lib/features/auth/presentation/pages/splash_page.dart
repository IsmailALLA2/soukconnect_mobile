import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _particleCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _logoFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _glowPulse;

  final _typewriterText = StringBuffer();
  final _fullTagline = 'Le marché de gros connecté';
  Timer? _typewriterTimer;
  int _typewriterIndex = 0;

  final _particles = List.generate(8, (_) => _ParticleData());

  @override
  void initState() {
    super.initState();

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

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _scale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _particleCtrl,
        curve: Curves.easeInOut,
      ),
    );

    _ctrl.forward();

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_typewriterIndex < _fullTagline.length) {
        setState(() => _typewriterText.write(_fullTagline[_typewriterIndex]));
        _typewriterIndex++;
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _particleCtrl.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _particleCtrl]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.success,
                  AppColors.primaryLight,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // ── Particles ──────────────────────────────────────
                  ..._particles.map((p) => Positioned(
                        left: p.x.w +
                            (_particleCtrl.value * 30.w * p.driftX),
                        top: ((p.y - _particleCtrl.value * 100) % 100).h,
                        child: Opacity(
                          opacity: p.opacity *
                              (1 - _particleCtrl.value % 1.0).clamp(0, 1),
                          child: Container(
                            width: p.size.w,
                            height: p.size.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      )),

                  // ── Content ────────────────────────────────────────
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo with glow ───────────────────────────
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
                                    color: AppColors.white.withValues(
                                        alpha: 0.15 * _glowPulse.value),
                                    blurRadius: 20.r + 10.r * _glowPulse.value,
                                    offset: Offset(0, 4.h),
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

                        // ── App name ─────────────────────────────────
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

                        // ── Typewriter tagline ───────────────────────
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            _typewriterText.toString(),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.white.withValues(alpha: 0.72),
                            ).copyWith(letterSpacing: 0.3),
                          ),
                        ),
                        SizedBox(height: 72.h),

                        // ── Pulsing dots ─────────────────────────────
                        FadeTransition(
                          opacity: _taglineFade,
                          child: const _PulsingDots(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParticleData {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double driftX;

  _ParticleData()
      : x = math.Random().nextDouble() * 80 + 10,
        y = math.Random().nextDouble() * 60 + 20,
        size = math.Random().nextDouble() * 4 + 2,
        opacity = math.Random().nextDouble() * 0.4 + 0.1,
        driftX = (math.Random().nextDouble() - 0.5) * 2;
}

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
