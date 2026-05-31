import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sizer.dart';

/// An animated notification badge that bounces on count change.
///
/// Shows "99+" when [count] exceeds 99. Hides itself when count is 0.
class CountBadge extends StatefulWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.color = AppColors.error,
    this.size = 20,
  });

  final int count;
  final Color color;
  final double size;

  @override
  State<CountBadge> createState() => _CountBadgeState();
}

class _CountBadgeState extends State<CountBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void didUpdateWidget(CountBadge old) {
    super.didUpdateWidget(old);
    if (old.count != widget.count && widget.count > 0) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    final label = widget.count > 99 ? '99+' : widget.count.toString();

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.scale(
        scale: 0.7 + _anim.value * 0.3,
        child: child,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.size / 2),
        ),
        constraints: BoxConstraints(minWidth: widget.size),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
