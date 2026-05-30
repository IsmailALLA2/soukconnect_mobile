import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class CartFloatingButton extends StatelessWidget {
  const CartFloatingButton({super.key, required this.totalItems, required this.onTap});
  final int totalItems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16.r),
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_rounded, size: 20.sp, color: AppColors.white),
              SizedBox(width: 8.w),
              Text(
                'Voir le panier',
                style: AppTextStyles.labelLarge(color: AppColors.white),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$totalItems',
                  style: AppTextStyles.labelMedium(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
