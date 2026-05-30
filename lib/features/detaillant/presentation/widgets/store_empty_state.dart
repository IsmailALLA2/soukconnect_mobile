import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreEmptyState
// Shown inside SliverFillRemaining when the nearby store list is empty.
// ─────────────────────────────────────────────────────────────────────────────

class StoreEmptyState extends StatelessWidget {
  const StoreEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96.w,
            height: 96.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_mall_directory_outlined,
              size: 44.sp,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Aucun grossiste trouvé près de vous',
            style: AppTextStyles.titleSmall(
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            "Essayez d'élargir la zone de recherche\nou de changer de catégorie.",
            style: AppTextStyles.bodyMedium(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
