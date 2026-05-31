import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../providers/product_management_provider.dart';
import 'product_form_sheet.dart';

class ProductListItem extends ConsumerWidget {
  const ProductListItem({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(30.w * (1 - value), 0),
            child: child,
          ),
        );
      },
      child: Dismissible(
        key: ValueKey('product_${product.id}'),
        direction: DismissDirection.horizontal,
        background: _deleteBackground(context),
        secondaryBackground: _editBackground(context),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await showEditProductSheet(context, product);
            return false;
          }
          final confirmed = await _confirmDelete(context);
          if (confirmed == true) {
            await ref
                .read(myProductsNotifierProvider(product.storeId).notifier)
                .deleteProduct(product.id);
          }
          return false;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Card(
            elevation: 1,
            shadowColor: AppColors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
              side: BorderSide(color: AppColors.grey200),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  _ProductImage(product: product),
                  SizedBox(width: 12.w),
                  Expanded(
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
                        Row(
                          children: [
                            Text(
                              '${product.price.toStringAsFixed(0)} MAD',
                              style: AppTextStyles.bodyMedium(
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '/ ${product.unit}',
                              style: AppTextStyles.bodySmall(
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        _StockBadge(stock: product.stock),
                      ],
                    ),
                  ),
                  SizedBox(width: 4.w),
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
                          activeTrackColor: AppColors.success.withValues(alpha: 0.4),
                          activeThumbColor: AppColors.success,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      SizedBox(height: 6.h),
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
                              icon: Icon(
                                Icons.delete_outline_rounded,
                                size: 16.sp,
                              ),
                              color: AppColors.error,
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final confirmed = await _confirmDelete(context);
                                if (confirmed == true) {
                                  await ref
                                      .read(myProductsNotifierProvider(
                                              product.storeId)
                                          .notifier)
                                      .deleteProduct(product.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(14.r),
      ),
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: 24.w),
      child: Icon(Icons.delete_rounded, color: AppColors.white, size: 24.sp),
    );
  }

  Widget _editBackground(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14.r),
      ),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 24.w),
      child: Icon(Icons.edit_rounded, color: AppColors.white, size: 24.sp),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return AppDialog.confirm(
      context,
      title: 'Supprimer le produit',
      message: 'Êtes-vous sûr de vouloir supprimer ce produit ?\nCette action est irréversible.',
      onConfirm: () {},
      type: DialogType.danger,
      confirmLabel: 'Supprimer',
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: SizedBox(
        width: 60.w,
        height: 60.w,
        child: product.hasImage
            ? CachedNetworkImage(
                imageUrl: product.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _placeholder(),
                errorWidget: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty
              ? product.name[0].toUpperCase()
              : '?',
          style: AppTextStyles.titleLarge(color: AppColors.white),
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
