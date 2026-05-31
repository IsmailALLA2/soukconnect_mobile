import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/sizer.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final bool isCircle;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkSurfaceVar : AppColors.grey200;
    final highlight =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value) ?? base,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius.r),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 8,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (i) {
        return Padding(
          padding: EdgeInsets.only(top: i > 0 ? spacing.h : 0),
          child: itemBuilder(context, i),
        );
      }),
    );
  }
}
