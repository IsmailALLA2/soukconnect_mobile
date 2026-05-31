import 'package:flutter/material.dart';

/// Wraps [child] with a scale-down-on-tap animation.
///
/// Scales to 0.95 on pointer down, back to 1.0 on release/cancel
/// (100 ms ease-out). Calls [onTap] on tap-up.
class AnimatedTap extends StatefulWidget {
  const AnimatedTap({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleDuration = const Duration(milliseconds: 100),
  });

  final Widget child;
  final VoidCallback onTap;
  final Duration scaleDuration;

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.scaleDuration);
    _anim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Transform.scale(
          scale: _anim.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
