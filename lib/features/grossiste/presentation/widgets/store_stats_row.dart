import 'package:flutter/material.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../shared/widgets/charts/charts.dart';
import '../../domain/entities/my_store_entity.dart';

class StoreStatsRow extends StatelessWidget {
  const StoreStatsRow({super.key, required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        icon: Icons.inventory_2_rounded,
        label: 'Produits',
        value: store.totalProducts.toDouble(),
        suffix: null,
        gradient: AppColors.gradient1,
      ),
      _StatData(
        icon: Icons.receipt_long_rounded,
        label: 'Commandes',
        value: store.totalOrders.toDouble(),
        suffix: null,
        gradient: AppColors.gradient3,
      ),
      _StatData(
        icon: Icons.hourglass_bottom_rounded,
        label: 'En attente',
        value: store.pendingOrders.toDouble(),
        suffix: null,
        gradient: AppColors.gradient2,
      ),
      _StatData(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Revenus',
        value: store.totalRevenue,
        suffix: ' MAD',
        gradient: AppGradients.successGreen,
      ),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
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
        itemBuilder: (context, index) {
          final s = stats[index];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Interval(
              (index * 0.1).clamp(0.0, 0.5),
              1.0,
              curve: Curves.easeOutCubic,
            ),
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20.h * (1 - value)),
                child: child,
              ),
            ),
            child: _StatCard(s: s),
          );
        },
      ),
    );
  }

}

class _StatData {
  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
    required this.gradient,
  });

  final IconData icon;
  final String label;
  final double value;
  final String? suffix;
  final Gradient gradient;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.s});

  final _StatData s;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: s.gradient,
      padding: EdgeInsets.all(12.w),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.label,
                style: AppTextStyles.labelSmall(color: AppColors.white),
              ),
              Icon(
                s.icon,
                size: 18.sp,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          AnimatedCounter(
            targetValue: s.value,
            suffix: s.suffix,
            style: AppTextStyles.titleLarge(color: AppColors.white),
          ),
          const Spacer(),
          SizedBox(
            height: 32.h,
            child: MiniSparkline(
              values: _sparklineValues(s.value),
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _sparklineValues(double value) {
    final base = value / 7;
    if (base <= 0) return [1.0, 2.0, 1.0, 3.0, 2.0, 4.0, 2.0];
    return [1.2, 0.8, 1.1, 0.9, 1.3, 0.7, 1.0]
        .map((f) => (base * f).clamp(0.0, double.infinity))
        .toList();
  }
}
