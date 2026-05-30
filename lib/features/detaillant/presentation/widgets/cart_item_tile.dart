import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';

class CartItemTile extends HookConsumerWidget {
  const CartItemTile({super.key, required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartNotifierProvider.notifier);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 60.w,
              height: 60.w,
              color: context.isDark ? AppColors.grey800 : AppColors.grey100,
              child: item.product.hasImage
                  ? Image.network(item.product.imageUrl!, fit: BoxFit.cover)
                  : Icon(Icons.image_outlined, color: AppColors.grey400),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.labelMedium(color: context.colorScheme.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.product.price.toStringAsFixed(2)} MAD',
                  style: AppTextStyles.bodySmall(color: AppColors.primary),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            children: [
              _QtyButton(
                icon: Icons.remove_rounded,
                onPressed: () => notifier.decrementItem(item.product.id),
                background: AppColors.grey200,
              ),
              SizedBox(
                width: 32.w,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
                ),
              ),
              _QtyButton(
                icon: Icons.add_rounded,
                onPressed: () => notifier.incrementItem(item.product.id),
                background: AppColors.primaryLight.withValues(alpha: 0.15),
              ),
            ],
          ),
          SizedBox(width: 4.w),
          Text(
            '${item.subtotal.toStringAsFixed(2)} MAD',
            style: AppTextStyles.labelMedium(color: context.colorScheme.onSurface),
          ),
          SizedBox(width: 4.w),
          IconButton(
            onPressed: () => notifier.removeItem(item.product.id),
            icon: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.error),
            iconSize: 18.sp,
            style: IconButton.styleFrom(minimumSize: Size(30.w, 30.w)),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed, required this.background});
  final IconData icon;
  final VoidCallback onPressed;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      iconSize: 18.sp,
      style: IconButton.styleFrom(
        backgroundColor: background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
        minimumSize: Size(30.w, 30.w),
      ),
    );
  }
}
