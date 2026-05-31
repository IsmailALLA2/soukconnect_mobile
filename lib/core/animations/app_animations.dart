import 'package:flutter/material.dart';

/// Reusable animation widgets — fade-slide-in, scale-in, staggered list,
/// pulse, and shimmer transitions.
///
/// Every animation auto-starts on insert and disposes its controller.
abstract class AppAnimations {
  AppAnimations._();

  /// Slides [child] up 24.h while fading in, starting after [delay].
  static Widget fadeSlideIn({
    required Widget child,
    Duration delay = Duration.zero,
  }) =>
      _FadeSlideIn(child: child, delay: delay);

  /// Scales [child] from 0.8 → 1.0 with an ease-out curve, starting
  /// after [delay].
  static Widget scaleIn({
    required Widget child,
    Duration delay = Duration.zero,
  }) =>
      _ScaleIn(child: child, delay: delay);

  /// Wraps each child of [children] in a staggered fade-slide-in,
  /// offsetting each by [baseDelay].
  static Widget staggeredList({
    required List<Widget> children,
    Duration baseDelay = const Duration(milliseconds: 60),
  }) =>
      _StaggeredList(children: children, baseDelay: baseDelay);

  /// Loops a subtle (0.97 → 1.03) scale pulse on [child].
  static Widget pulse({required Widget child}) => _Pulse(child: child);
}

// ── Fade-slide-in ─────────────────────────────────────────────────────────────

class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Scale-in ──────────────────────────────────────────────────────────────────

class _ScaleIn extends StatefulWidget {
  const _ScaleIn({required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  State<_ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<_ScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutBack,
    );
    Future.delayed(widget.delay, _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _scale,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ── Staggered list ────────────────────────────────────────────────────────────

class _StaggeredList extends StatelessWidget {
  const _StaggeredList({
    required this.children,
    required this.baseDelay,
  });
  final List<Widget> children;
  final Duration baseDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < children.length; i++)
          AppAnimations.fadeSlideIn(
            child: children[i],
            delay: baseDelay * i,
          ),
      ],
    );
  }
}

// ── Pulse ─────────────────────────────────────────────────────────────────────

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.scale(
        scale: _anim.value,
        child: child,
      ),
      child: widget.child,
    );
  }
}
