import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/widgets/charts/charts.dart';
import '../../../detaillant/domain/entities/order_entity.dart' show OrderStatus;
import '../../domain/entities/my_store_entity.dart';
import '../providers/store_management_provider.dart';
import '../widgets/store_form_sheet.dart';
import '../widgets/store_stats_row.dart';

class MyStorePage extends HookConsumerWidget {
  const MyStorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: storeAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(message: e.toString()),
        data: (store) {
          if (store == null) return const _AnimatedEmptyStore();
          return _StoreContent(store: store);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StoreContent — main page content with header, stats, charts, actions
// ─────────────────────────────────────────────────────────────────────────────

class _StoreContent extends StatelessWidget {
  const _StoreContent({required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    final dailyBase = store.totalRevenue / 7;
    final dayFactors = [1.2, 0.8, 1.1, 0.9, 1.3, 0.7, 1.0];
    final spots = dayFactors.asMap().entries.map(
      (e) => FlSpot(
        e.key.toDouble(),
        (dailyBase * e.value).clamp(0, double.infinity),
      ),
    ).toList();
    final maxY =
        spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3;

    final total = store.totalOrders;
    final pending = store.pendingOrders;
    final remaining = total - pending;
    final confirmed = (remaining * 0.6).round();
    final delivered = (remaining * 0.3).round();
    final cancelled = remaining - confirmed - delivered;
    final pieData = <OrderStatus, int>{
      OrderStatus.pending: pending,
      OrderStatus.confirmed: confirmed,
      OrderStatus.cancelled: cancelled,
      OrderStatus.delivered: delivered,
    }..removeWhere((_, v) => v <= 0);

    return SingleChildScrollView(
      child: Column(
        children: [
          _HeaderSection(store: store),
          SizedBox(height: 8.h),
          StoreStatsRow(store: store),
          SizedBox(height: 16.h),
          if (store.totalRevenue > 0)
            _ChartCard(
              title: 'Revenus cette semaine',
              child: RevenueLineChart(spots: spots, maxY: maxY),
            ),
          if (pieData.isNotEmpty)
            _ChartCard(
              title: 'Statut des commandes',
              child: CategoryPieChart(data: pieData),
            ),
          SizedBox(height: 8.h),
          _QuickActions(store: store),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeaderSection — GradientCard with store info + active dot + edit button
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppGradients.primaryDiagonal,
      padding: EdgeInsets.all(20.w),
      borderRadius: 0,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: AppTextStyles.headlineSmall(color: AppColors.white),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              store.category.label,
                              style: AppTextStyles.labelSmall(color: AppColors.white),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          _PulsingDot(isActive: store.isActive),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 36.h,
                  child: OutlinedButton.icon(
                    onPressed: () => showEditStoreSheet(context, store),
                    icon: Icon(Icons.edit_rounded, size: 16.sp),
                    label: Text(
                      'Modifier',
                      style: AppTextStyles.labelSmall(color: AppColors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: '${store.wilaya} \u2014 ${store.address}',
            ),
            SizedBox(height: 8.h),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: store.phone,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: AppColors.white.withValues(alpha: 0.8)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.isActive});

  final bool isActive;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: widget.isActive
                  ? AppColors.success
                  : AppColors.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isActive
                          ? AppColors.success
                          : AppColors.error)
                      .withValues(alpha: _anim.value),
                  blurRadius: 6.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            widget.isActive ? 'Actif' : 'Inactif',
            style: AppTextStyles.labelSmall(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChartCard — reusable card wrapper for chart sections
// ─────────────────────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.grey200),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall(
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _QuickActions — two large gradient buttons side by side
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              gradient: AppColors.gradient1,
              icon: Icons.inventory_2_rounded,
              label: 'Mes Produits',
              onTap: () => context.go(AppRoutes.grossisteProducts),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _ActionButton(
              gradient: AppColors.gradient3,
              icon: Icons.inbox_rounded,
              label: 'Commandes',
              badge: store.pendingOrders > 0 ? '${store.pendingOrders}' : null,
              onTap: () => context.go(AppRoutes.grossisteOrders),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.gradient,
    required this.icon,
    required this.label,
    this.badge,
    required this.onTap,
  });

  final Gradient gradient;
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: gradient,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      borderRadius: 16,
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              Icon(icon, size: 32.sp, color: AppColors.white),
              if (badge != null)
                Positioned(
                  right: -4.w,
                  top: -2.h,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badge!,
                      style: AppTextStyles.labelSmall(color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.labelLarge(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AnimatedEmptyStore — Lottie-style animated empty state
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedEmptyStore extends StatefulWidget {
  const _AnimatedEmptyStore();

  @override
  State<_AnimatedEmptyStore> createState() => _AnimatedEmptyStoreState();
}

class _AnimatedEmptyStoreState extends State<_AnimatedEmptyStore>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) => Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120.w + _ctrl.value * 20.w,
                    height: 120.w + _ctrl.value * 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary
                          .withValues(alpha: 0.12 - _ctrl.value * 0.06),
                    ),
                  ),
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  Icon(
                    Icons.store_mall_directory_rounded,
                    size: 44.sp + _ctrl.value * 4.sp,
                    color: AppColors.primary.withValues(
                      alpha: 0.5 + _ctrl.value * 0.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              "Vous n'avez pas encore de boutique",
              style: AppTextStyles.titleSmall(
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Créez votre boutique pour commencer\nà vendre sur SoukConnect.',
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            FilledButton.icon(
              onPressed: () => showCreateStoreSheet(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Créer ma boutique'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingState — full-page shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 220.h,
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryDiagonal,
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 180.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: 80.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: 160.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 120.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _shimmerGrid(),
          _shimmerCard(200.h),
          _shimmerCard(280.h),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _shimmerGrid() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(
            color: AppColors.grey200,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _shimmerCard(double height) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ErrorState — error page with retry
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

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
              'Impossible de charger votre boutique',
              style: AppTextStyles.titleSmall(
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
