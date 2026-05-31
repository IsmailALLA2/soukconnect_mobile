import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../shared/widgets/profile_page.dart';
import '../pages/cart_page.dart';
import '../pages/my_orders_page.dart';
import '../pages/nearby_stores_page.dart';
import '../providers/cart_provider.dart';

/// Bottom navigation shell for the Détaillant role.
class DetaillantShell extends HookConsumerWidget {
  const DetaillantShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    AppRoutes.detaillantStores,
    AppRoutes.detaillantCart,
    AppRoutes.detaillantOrders,
    AppRoutes.detaillantProfile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));
    final index = currentIndex < 0 ? 0 : currentIndex;

    final cart = ref.watch(cartNotifierProvider);
    final cartCount = cart.fold<int>(0, (sum, item) => sum + item.quantity);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: index,
        children: const [
          NearbyStoresPage(),
          CartPage(),
          MyOrdersPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        onTap: (i) => context.go(_tabs[i]),
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_outlined),
            activeIcon: const Icon(Icons.receipt_long),
            label: context.l10n.myOrders,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
