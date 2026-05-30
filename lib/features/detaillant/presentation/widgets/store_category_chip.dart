import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreCategoryChip
// A pill-shaped chip used in the horizontal category filter row.
// ─────────────────────────────────────────────────────────────────────────────

class StoreCategoryChip extends StatelessWidget {
  const StoreCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall(
            color: isSelected ? AppColors.white : AppColors.grey700,
          ),
        ),
      ),
    );
  }
}
