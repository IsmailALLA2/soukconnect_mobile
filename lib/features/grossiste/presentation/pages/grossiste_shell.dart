import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/connectivity_banner.dart';
import '../../../../core/widgets/count_badge.dart';
import '../../../../shared/widgets/profile_page.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../pages/incoming_orders_page.dart';
import '../pages/my_products_page.dart';
import '../pages/my_store_page.dart';
import '../providers/incoming_orders_provider.dart';
import '../providers/store_management_provider.dart';

/// Bottom navigation shell for the Grossiste role.
class GrossisteShell extends HookConsumerWidget {
  const GrossisteShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    AppRoutes.grossisteStore,
    AppRoutes.grossisteProducts,
    AppRoutes.grossisteOrders,
    AppRoutes.grossisteProfile,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _tabs.indexWhere((t) => location.startsWith(t));
    final index = currentIndex < 0 ? 0 : currentIndex;

    final storeAsync = ref.watch(myStoreNotifierProvider);
    final storeId = storeAsync.valueOrNull?.id;

    int pendingCount = 0;
    if (storeId != null) {
      final ordersAsync = ref.watch(incomingOrdersNotifierProvider(storeId));
      pendingCount = ordersAsync.valueOrNull
              ?.where((o) => o.statusEnum == OrderStatus.pending)
              .length ??
          0;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: ConnectivityBanner(
        child: IndexedStack(
          index: index,
          children: const [
            MyStorePage(),
            MyProductsPage(),
            IncomingOrdersPage(),
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
            label: 'Boutique',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 1,
              icon: const Icon(Icons.inventory_2_outlined),
              activeIcon: const Icon(Icons.inventory_2),
            ),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: _NavIcon(
              isSelected: index == 2,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.inbox_outlined),
                  if (pendingCount > 0)
                    Positioned(
                      right: -10.w,
                      top: -4.h,
                      child: CountBadge(count: pendingCount),
                    ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.inbox),
                  if (pendingCount > 0)
                    Positioned(
                      right: -10.w,
                      top: -4.h,
                      child: CountBadge(count: pendingCount),
                    ),
                ],
              ),
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
