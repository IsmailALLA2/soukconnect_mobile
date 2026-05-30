import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

enum _ChipVariant { normal, darkStyle }

class StoreInlineCategoryChip extends StatelessWidget {
  const StoreInlineCategoryChip({super.key, required this.label})
    : _variant = _ChipVariant.normal;

  const StoreInlineCategoryChip.darkStyle({super.key, required this.label})
    : _variant = _ChipVariant.darkStyle;

  final String label;
  final _ChipVariant _variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: _variant == _ChipVariant.darkStyle ? 3.h : 2.h,
      ),
      decoration: BoxDecoration(
        color: _variant == _ChipVariant.darkStyle
            ? AppColors.white.withValues(alpha: 0.2)
            : AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_variant == _ChipVariant.darkStyle ? 20.r : 6.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(
          color: _variant == _ChipVariant.darkStyle
              ? AppColors.white
              : AppColors.secondaryDark,
        ),
      ),
    );
  }
}
