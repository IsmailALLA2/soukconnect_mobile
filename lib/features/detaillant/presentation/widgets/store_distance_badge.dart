import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreDistanceBadge
// Green pill showing distance in metres (< 1 km) or kilometres.
// ─────────────────────────────────────────────────────────────────────────────

class StoreDistanceBadge extends StatelessWidget {
  const StoreDistanceBadge({super.key, required this.km});

  final double km;

  @override
  Widget build(BuildContext context) {
    final label = km < 1
        ? '${(km * 1000).round()} m'
        : '${km.toStringAsFixed(1)} km';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 10.sp, color: AppColors.primary),
          SizedBox(width: 3.w),
          Text(
            label,
            style: AppTextStyles.labelSmall(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
