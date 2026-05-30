import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/cart_provider.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({super.key, required this.products, required this.storeId});
  final List<ProductEntity> products;
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(
            product: products[index],
            onAdd: () {
              final result = ref
                  .read(cartNotifierProvider.notifier)
                  .addItem(CartItem(
                    product: products[index],
                    quantity: 1,
                    storeId: storeId,
                  ));
              if (result is CartAdded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${products[index].name} ajouté au panier'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (result is CartStoreConflict) {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    title: const Text('Changer de boutique'),
                    content: const Text(
                      'Votre panier contient déjà des produits d\'une autre '
                      'boutique. Voulez-vous vider le panier et ajouter ce '
                      'produit ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(cartNotifierProvider.notifier)
                              .forceClearAndAdd(CartItem(
                                product: products[index],
                                quantity: 1,
                                storeId: storeId,
                              ));
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${products[index].name} ajouté au panier',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Vider et ajouter'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAdd});
  final ProductEntity product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final inStock = product.inStock;
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.grey200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: product.hasImage
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: context.isDark ? AppColors.grey800 : AppColors.grey100,
                    ),
                    errorWidget: (_, _, _) => const _ImagePlaceholder(),
                  )
                : const _ImagePlaceholder(),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.labelMedium(color: context.colorScheme.onSurface),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '${product.price.toStringAsFixed(2)} MAD / ${product.unit}',
                    style: AppTextStyles.bodySmall(color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: inStock ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          inStock ? 'En stock' : 'Rupture',
                          style: AppTextStyles.labelSmall(
                            color: inStock ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 30.w,
                        height: 30.w,
                        child: IconButton(
                          onPressed: inStock ? onAdd : null,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.add_rounded,
                            size: 18.sp,
                            color: inStock ? AppColors.primary : AppColors.grey400,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: inStock
                                ? AppColors.primaryLight.withValues(alpha: 0.15)
                                : AppColors.grey200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.isDark ? AppColors.grey800 : AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_outlined, size: 32.sp, color: AppColors.grey400),
      ),
    );
  }
}
