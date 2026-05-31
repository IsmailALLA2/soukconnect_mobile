import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A brand-consistent loading spinner: 3 rotating dots in AppColors.primary.
class GreenSpinner extends StatefulWidget {
  const GreenSpinner({
    super.key,
    this.size = 24,
    this.color = AppColors.primary,
  });

  final double size;
  final Color color;

  @override
  State<GreenSpinner> createState() => _GreenSpinnerState();
}

class _GreenSpinnerState extends State<GreenSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
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
        return SizedBox(
          width: widget.size,
          height: widget.size * 0.35,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              final phase = (i / 3 + _ctrl.value) % 1.0;
              final opacity = phase < 0.5
                  ? 1.0 - phase * 2
                  : (phase - 0.5) * 2;
              final scale = 0.4 + opacity * 0.6;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.22,
                  height: widget.size * 0.22,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
