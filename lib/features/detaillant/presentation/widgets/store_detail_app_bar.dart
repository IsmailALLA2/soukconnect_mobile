import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/store_entity.dart';
import 'store_inline_category_chip.dart';

class StoreSliverAppBar extends StatelessWidget {
  const StoreSliverAppBar({super.key, required this.store});
  final StoreEntity store;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, size: 22.sp),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, bottom: 24.h, right: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.name,
                style: AppTextStyles.headlineSmall(color: AppColors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  StoreInlineCategoryChip.darkStyle(label: store.category.label),
                  SizedBox(width: 8.w),
                  Icon(Icons.location_on_rounded, size: 14.sp, color: AppColors.white),
                  SizedBox(width: 3.w),
                  Text(
                    store.wilaya,
                    style: AppTextStyles.bodySmall(color: AppColors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingSliverAppBar extends StatelessWidget {
  const LoadingSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, size: 22.sp),
        onPressed: () => GoRouter.of(context).pop(),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
      ),
    );
  }
}
