import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/my_store_entity.dart';
import 'store_form_sheet.dart';

class StoreInfoCard extends StatelessWidget {
  const StoreInfoCard({super.key, required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: AppTextStyles.titleLarge(color: AppColors.white),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        store.category.label,
                        style: AppTextStyles.labelSmall(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36.h,
                child: OutlinedButton.icon(
                  onPressed: () => showEditStoreSheet(context, store),
                  icon: Icon(Icons.edit_rounded, size: 16.sp),
                  label: Text(
                    'Modifier',
                    style: AppTextStyles.labelSmall(color: AppColors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.white.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _InfoRow(
            icon: Icons.location_on_outlined,
            text: '${store.wilaya} — ${store.address}',
          ),
          SizedBox(height: 8.h),
          _InfoRow(
            icon: Icons.phone_outlined,
            text: store.phone,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.white.withValues(alpha: 0.8)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(color: AppColors.white.withValues(alpha: 0.9)),
          ),
        ),
      ],
    );
  }
}
