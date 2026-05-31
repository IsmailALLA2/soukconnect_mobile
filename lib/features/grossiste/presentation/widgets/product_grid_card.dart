import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import 'product_form_sheet.dart';

class ProductGridCard extends ConsumerWidget {
  const ProductGridCard({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: GestureDetector(
        onTap: () => showEditProductSheet(context, product),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 1,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: product.hasImage
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _productPlaceholder(),
                        errorWidget: (_, _, _) => _productPlaceholder(),
                      )
                    : _productPlaceholder(),
              ),
              Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.titleSmall(
                        color: context.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${product.price.toStringAsFixed(0)} MAD / ${product.unit}',
                      style: AppTextStyles.bodyMedium(color: AppColors.primary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    _StockBadge(stock: product.stock),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      height: 32.h,
                      child: OutlinedButton.icon(
                        onPressed: () => showEditProductSheet(context, product),
                        icon: Icon(Icons.edit_rounded, size: 14.sp),
                        label: Text(
                          'Modifier',
                          style: AppTextStyles.labelSmall(color: AppColors.primary),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productPlaceholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Text(
          product.name.isNotEmpty
              ? product.name[0].toUpperCase()
              : '?',
          style: AppTextStyles.displaySmall(color: AppColors.grey400),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (stock) {
      0 => (AppColors.error, 'Rupture'),
      _ when stock >= 1 && stock <= 10 => (
        AppColors.warning,
        'Stock faible: $stock',
      ),
      _ => (AppColors.success, 'En stock: $stock'),
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
