import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class StoreActionCard extends StatelessWidget {
  const StoreActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      child: Card(
        child: Column(
          children: [
            _ActionTile(
              icon: Icons.inventory_2_outlined,
              title: 'Mes produits',
              subtitle: 'Gérer votre catalogue',
              onTap: () => context.go(AppRoutes.grossisteProducts),
            ),
            const Divider(height: 1),
            _ActionTile(
              icon: Icons.inbox_outlined,
              title: 'Commandes entrantes',
              subtitle: 'Voir les commandes reçues',
              onTap: () => context.go(AppRoutes.grossisteOrders),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleSmall(color: AppColors.grey900),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall(color: AppColors.grey500),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14.sp,
        color: AppColors.grey400,
      ),
      onTap: onTap,
    );
  }
}
