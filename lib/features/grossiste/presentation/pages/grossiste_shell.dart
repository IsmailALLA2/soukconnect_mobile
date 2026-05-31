import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
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
      body: IndexedStack(
        index: index,
        children: const [
          MyStorePage(),
          MyProductsPage(),
          IncomingOrdersPage(),
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
            label: 'Boutique',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.inbox_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: pendingCount > 0,
              label: Text('$pendingCount'),
              child: const Icon(Icons.inbox),
            ),
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
