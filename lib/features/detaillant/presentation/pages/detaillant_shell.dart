import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/connectivity_banner.dart';
import '../../../../core/widgets/count_badge.dart';
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
      body: ConnectivityBanner(
        child: IndexedStack(
          index: index,
          children: const [
            NearbyStoresPage(),
            CartPage(),
            MyOrdersPage(),
            ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey500,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        onTap: (i) {
          HapticFeedback.selectionClick();
          context.go(_tabs[i]);
        },
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        items: [
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 0,
              icon: const Icon(Icons.store_outlined),
              activeIcon: const Icon(Icons.store),
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 1,
              icon: _cartIcon(cartCount, filled: false),
              activeIcon: _cartIcon(cartCount, filled: true),
            ),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 2,
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
            ),
            label: context.l10n.myOrders,
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 3,
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
            ),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

Widget _cartIcon(int cartCount, {required bool filled}) {
  final icon = filled
      ? const Icon(Icons.shopping_cart)
      : const Icon(Icons.shopping_cart_outlined);

  final stack = Stack(
    clipBehavior: Clip.none,
    children: [
      icon,
      if (cartCount > 0)
        Positioned(
          right: -10.w,
          top: -4.h,
          child: CountBadge(count: cartCount),
        ),
    ],
  );

  if (cartCount > 0) return AppAnimations.pulse(child: stack);
  return stack;
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.isSelected,
    required this.icon,
    required this.activeIcon,
  });

  final bool isSelected;
  final Widget icon;
  final Widget activeIcon;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: isSelected ? activeIcon : icon,
    );
  }
}
