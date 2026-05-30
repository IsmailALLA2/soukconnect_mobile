import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreShimmerList
// Animated loading placeholder — 3 shimmer cards as a SliverList.
// No external shimmer package; uses AnimationController + Color.lerp.
// ─────────────────────────────────────────────────────────────────────────────

class StoreShimmerList extends StatefulWidget {
  const StoreShimmerList({super.key});

  @override
  State<StoreShimmerList> createState() => _StoreShimmerListState();
}

class _StoreShimmerListState extends State<StoreShimmerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => AnimatedBuilder(
          animation: _anim,
          builder: (context, child) =>
              _StoreShimmerCard(opacity: _anim.value),
        ),
        childCount: 3,
      ),
    );
  }
}

// ── Single shimmer card ───────────────────────────────────────────────────────

class _StoreShimmerCard extends StatelessWidget {
  const _StoreShimmerCard({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final base         = context.isDark ? AppColors.grey700 : AppColors.grey200;
    final highlight    = context.isDark ? AppColors.grey600 : AppColors.grey100;
    final shimmerColor = Color.lerp(base, highlight, opacity)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Container(
        height: 90.h,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: shimmerColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: shimmerColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 12.w),
            // Text placeholders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Bar(width: 140.w, height: 14.h, color: shimmerColor),
                  SizedBox(height: 8.h),
                  _Bar(width: 90.w,  height: 10.h, color: shimmerColor),
                  SizedBox(height: 6.h),
                  _Bar(width: 180.w, height: 10.h, color: shimmerColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width:  width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
