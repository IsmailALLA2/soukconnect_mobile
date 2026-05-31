import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/my_store_entity.dart';

class StoreStatsRow extends StatelessWidget {
  const StoreStatsRow({super.key, required this.store});

  final MyStoreEntity store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_2_outlined,
              value: store.totalProducts.toString(),
              label: 'Produits',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.receipt_long_outlined,
              value: store.totalOrders.toString(),
              label: 'Commandes',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.hourglass_empty_outlined,
              value: store.pendingOrders.toString(),
              label: 'En attente',
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _StatCard(
              icon: Icons.account_balance_wallet_outlined,
              value: store.totalRevenue.toStringAsFixed(0),
              label: 'Revenus',
              suffix: ' MAD',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.suffix,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        child: Column(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppTextStyles.titleSmall(color: AppColors.grey900),
                  ),
                  if (suffix != null)
                    TextSpan(
                      text: suffix,
                      style: AppTextStyles.labelSmall(color: AppColors.grey500),
                    ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
