import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../widgets/widgets.dart';

part 'my_orders_page.g.dart';

@riverpod
OrderRepository _orderRepository(_OrderRepositoryRef ref) =>
    OrderRepositoryImpl();

@riverpod
Future<List<OrderEntity>> myOrdersList(MyOrdersListRef ref) async {
  final user = ref.watch(authNotifierProvider.notifier).currentUser;
  if (user == null) return [];
  final repo = ref.watch(_orderRepositoryProvider);
  return repo.getMyOrders(user.id);
}

class MyOrdersPage extends HookConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (orders) {
          if (orders.isEmpty) return const _EmptyView();
          return RefreshIndicator(
            onRefresh: () => ref.refresh(myOrdersListProvider.future),
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: orders.length,
              itemBuilder: (_, i) => OrderCard(order: orders[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64.sp, color: AppColors.grey300),
          SizedBox(height: 16.h),
          Text(
            'Aucune commande',
            style: AppTextStyles.titleMedium(
              color: AppColors.grey500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Vos commandes apparaîtront ici.',
            style: AppTextStyles.bodyMedium(color: AppColors.grey400),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'Impossible de charger vos commandes',
              style: AppTextStyles.titleSmall(
                color: AppColors.grey600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: AppColors.grey400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
