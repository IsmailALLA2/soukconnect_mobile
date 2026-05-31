import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/green_spinner.dart';
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
    final theme = context.colorScheme;

    final orders = ordersAsync.valueOrNull ?? [];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes commandes'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Toutes'),
              _tabWithBadge('En attente', orders, OrderStatus.pending),
              _tabWithBadge('Confirmées', orders, OrderStatus.confirmed),
              _tabWithBadge('Livrées', orders, OrderStatus.delivered),
            ],
            isScrollable: false,
            labelColor: theme.primary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: theme.primary,
            indicatorWeight: 3,
          ),
        ),
        body: ordersAsync.when(
          loading: () => const Center(child: GreenSpinner()),
          error: (e, _) => _ErrorView(message: e.toString()),
          data: (data) => _MyOrdersBody(orders: data),
        ),
      ),
    );
  }

  Widget _tabWithBadge(String label, List<OrderEntity> orders, OrderStatus status) {
    final count = orders.where((o) => o.statusEnum == status).length;
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            SizedBox(width: 4.w),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 600),
              builder: (_, value, __) => Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$value',
                  style: AppTextStyles.labelSmall(color: AppColors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.success;
      case OrderStatus.delivered:
        return AppColors.info;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}

class _MyOrdersBody extends StatelessWidget {
  const _MyOrdersBody({required this.orders});

  final List<OrderEntity> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const _EmptyView();
    }

    final pending = orders.where((o) => o.statusEnum == OrderStatus.pending).length;
    final confirmed = orders.where((o) => o.statusEnum == OrderStatus.confirmed).length;
    final delivered = orders.where((o) => o.statusEnum == OrderStatus.delivered).length;

    return Column(
      children: [
        _SummaryStrip(
          total: orders.length,
          pending: pending,
          confirmed: confirmed,
          delivered: delivered,
        ),
        Expanded(
          child: TabBarView(
            children: [
              _OrderListView(orders: orders, filter: _filterNone),
              _OrderListView(orders: orders, filter: _filterPending),
              _OrderListView(orders: orders, filter: _filterConfirmed),
              _OrderListView(orders: orders, filter: _filterDelivered),
            ],
          ),
        ),
      ],
    );
  }

  List<OrderEntity> _filterNone(List<OrderEntity> items) => items;
  List<OrderEntity> _filterPending(List<OrderEntity> items) =>
      items.where((o) => o.statusEnum == OrderStatus.pending).toList();
  List<OrderEntity> _filterConfirmed(List<OrderEntity> items) =>
      items.where((o) => o.statusEnum == OrderStatus.confirmed).toList();
  List<OrderEntity> _filterDelivered(List<OrderEntity> items) =>
      items.where((o) => o.statusEnum == OrderStatus.delivered).toList();
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.delivered,
  });

  final int total;
  final int pending;
  final int confirmed;
  final int delivered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.receipt_long_rounded,
            label: 'Total',
            value: total,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.hourglass_empty_rounded,
            label: 'En attente',
            value: pending,
            color: AppColors.warning,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.check_circle_outline_rounded,
            label: 'Confirmées',
            value: confirmed,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.local_shipping_rounded,
            label: 'Livrées',
            value: delivered,
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(height: 4.h),
            AnimatedCounter(
              targetValue: value.toDouble(),
              style: AppTextStyles.titleSmall(color: color),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderListView extends StatelessWidget {
  const _OrderListView({
    required this.orders,
    required this.filter,
  });

  final List<OrderEntity> orders;
  final List<OrderEntity> Function(List<OrderEntity>) filter;

  @override
  Widget build(BuildContext context) {
    final filtered = filter(orders);

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'Aucune commande.',
          style: AppTextStyles.bodyMedium(color: AppColors.grey500),
        ),
      );
    }

    return AppRefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        itemCount: filtered.length,
        itemBuilder: (_, i) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: OrderCard(order: filtered[i]),
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAnimations.pulse(
              child: CustomPaint(
                size: Size(96.w, 96.w),
                painter: _CartPainter(),
              ),
            ),
            SizedBox(height: 24.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Pas encore de commandes',
                style: AppTextStyles.titleSmall(
                  color: context.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 350),
              child: Text(
                'Explorez les boutiques proches et\npassez votre première commande.',
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 500),
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.detaillantStores),
                icon: const Icon(Icons.store_rounded, size: 20),
                label: const Text('Explorer les boutiques'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Basket body
    final basketPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.55)
      ..lineTo(size.width * 0.3, size.height * 0.75)
      ..lineTo(size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..close();
    canvas.drawPath(basketPath, paint);

    // Handle
    final handlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.42),
        width: size.width * 0.35,
        height: size.height * 0.25,
      ),
      3.14159,
      3.14159,
      false,
      handlePaint,
    );

    // Wheels
    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.78), size.width * 0.04, dotPaint);
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.78), size.width * 0.04, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
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
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Impossible de charger vos commandes',
              style: AppTextStyles.titleSmall(color: AppColors.grey600),
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
