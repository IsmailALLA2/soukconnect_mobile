import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../providers/product_management_provider.dart';
import 'product_form_sheet.dart';

class ProductListItem extends ConsumerWidget {
  const ProductListItem({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 56.w,
                height: 56.w,
                child: product.hasImage
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          color: AppColors.grey100,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.grey400,
                          ),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.grey100,
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.grey400,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.grey100,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.grey400,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall(color: AppColors.grey900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} MAD',
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '/ ${product.unit}',
                        style: AppTextStyles.bodySmall(color: AppColors.grey500),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  _StockBadge(stock: product.stock),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24.h,
                  child: Switch(
                    value: product.isAvailable,
                    onChanged: (_) {
                      ref
                          .read(myProductsNotifierProvider(product.storeId)
                              .notifier)
                          .toggleAvailability(product);
                    },
                    activeThumbColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: IconButton(
                        icon: Icon(Icons.edit_rounded, size: 16.sp),
                        color: AppColors.grey600,
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            showEditProductSheet(context, product),
                      ),
                    ),
                    SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, size: 16.sp),
                        color: AppColors.error,
                        padding: EdgeInsets.zero,
                        onPressed: () => _confirmDelete(context, ref),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text(
          'Voulez-vous vraiment supprimer "${product.name}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(myProductsNotifierProvider(product.storeId).notifier)
          .deleteProduct(product.id);
    }
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (stock) {
      0        => (AppColors.error,    'Rupture'),
      _ when stock >= 1 && stock <= 10
               => (AppColors.warning,  '$stock en stock'),
      _        => (AppColors.success,  '$stock en stock'),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: color),
      ),
    );
  }
}
