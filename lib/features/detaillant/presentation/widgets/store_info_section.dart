import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/store_entity.dart';
import 'store_distance_badge.dart';

class StoreInfoSection extends StatelessWidget {
  const StoreInfoSection({super.key, required this.store});
  final StoreEntity store;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoTile(
              icon: Icons.phone_rounded,
              child: Text(
                store.phone,
                style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(store.phone),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            SizedBox(height: 8.h),
            _InfoTile(
              icon: Icons.location_on_rounded,
              child: Expanded(
                child: Text(
                  store.address,
                  style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (store.distanceInKm != null) ...[
                  StoreDistanceBadge(km: store.distanceInKm!),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => GoRouter.of(context).push('/detaillant/map/${store.id}'),
                    icon: Icon(Icons.map_rounded, size: 18.sp),
                    label: Text(
                      'Voir sur la carte',
                      style: AppTextStyles.labelLarge(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.child, this.onTap});
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 12.w),
            child,
          ],
        ),
      ),
    );
  }
}
