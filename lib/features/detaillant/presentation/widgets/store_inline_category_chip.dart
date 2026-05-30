import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreInlineCategoryChip
// Small rounded label shown inside a StoreCard (not interactive).
// ─────────────────────────────────────────────────────────────────────────────

class StoreInlineCategoryChip extends StatelessWidget {
  const StoreInlineCategoryChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: AppColors.secondaryDark),
      ),
    );
  }
}
