import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/store_entity.dart';
import 'store_distance_badge.dart';
import 'store_inline_category_chip.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreCard
// Tappable card displayed in the NearbyStoresPage list.
// ─────────────────────────────────────────────────────────────────────────────

class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.store,
    required this.onTap,
  });

  final StoreEntity  store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Material(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.grey200),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                // ── Store icon avatar ────────────────────────────────────────
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),

                // ── Store info ───────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + distance badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: AppTextStyles.titleSmall(
                                color: context.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (store.distanceInKm != null) ...[
                            SizedBox(width: 8.w),
                            StoreDistanceBadge(km: store.distanceInKm!),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),

                      // Category chip
                      StoreInlineCategoryChip(label: store.category.label),
                      SizedBox(height: 6.h),

                      // Wilaya + address
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12.sp,
                            color: AppColors.grey500,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              '${store.wilaya} · ${store.address}',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.grey500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),

                // ── Arrow ────────────────────────────────────────────────────
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.grey400,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
