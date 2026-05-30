import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class StoreMapInfoSheet extends StatelessWidget {
  const StoreMapInfoSheet({
    super.key,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    this.distance,
  });

  final String storeName;
  final String storeAddress;
  final String storePhone;
  final double? distance;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      minChildSize: 0.12,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              20.w, 12.h, 20.w, MediaQuery.paddingOf(context).bottom + 12.h,
            ),
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.store_rounded, color: AppColors.primary, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          storeAddress,
                          style: AppTextStyles.bodySmall(color: AppColors.grey500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _InfoRow(
                icon: Icons.location_on_rounded,
                child: Text(
                  distance != null
                      ? 'À ${distance!.toStringAsFixed(1)} km de vous'
                      : storeAddress,
                  style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
                ),
              ),
              SizedBox(height: 8.h),
              _InfoRow(
                icon: Icons.phone_rounded,
                child: Text(
                  storePhone,
                  style: AppTextStyles.bodyMedium(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.child});
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: AppColors.grey500),
          SizedBox(width: 8.w),
          Expanded(child: child),
        ],
      ),
    );
  }
}
