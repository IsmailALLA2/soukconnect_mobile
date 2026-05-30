import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../providers/store_provider.dart';
import '../widgets/widgets.dart';

class StoreDetailPage extends HookConsumerWidget {
  const StoreDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeId = GoRouterState.of(context).pathParameters['storeId']!;
    final storeAsync = ref.watch(storeDetailProvider(storeId));
    final productsAsync = ref.watch(storeProductsProvider(storeId));
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              storeAsync.when(
                data: (store) => StoreSliverAppBar(store: store),
                loading: () => const LoadingSliverAppBar(),
                error: (_, _) => const LoadingSliverAppBar(),
              ),

              storeAsync.when(
                data: (store) => StoreInfoSection(store: store),
                loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                error: (_, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                          SizedBox(height: 8.h),
                          Text(
                            'Impossible de charger la boutique',
                            style: AppTextStyles.bodyMedium(color: AppColors.error),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                  child: Text(
                    'Produits disponibles',
                    style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
                  ),
                ),
              ),

              productsAsync.when(
                loading: () => const ProductShimmerGrid(),
                error: (_, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 40.sp, color: AppColors.error),
                          SizedBox(height: 8.h),
                          Text(
                            'Erreur de chargement',
                            style: AppTextStyles.bodyMedium(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const EmptyProducts();
                  }
                  return ProductGrid(products: products, storeId: storeId);
                },
              ),

              if (cart.isNotEmpty)
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
            ],
          ),

          if (cart.isNotEmpty)
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: MediaQuery.paddingOf(context).bottom + 8.h,
              child: CartFloatingButton(
                totalItems: cart.fold<int>(0, (sum, item) => sum + item.quantity),
                onTap: () => GoRouter.of(context).push('/detaillant/cart'),
              ),
            ),
        ],
      ),
    );
  }
}
