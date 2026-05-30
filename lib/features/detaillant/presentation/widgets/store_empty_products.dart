import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class EmptyProducts extends StatelessWidget {
  const EmptyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 56.sp, color: AppColors.grey400),
            SizedBox(height: 12.h),
            Text(
              'Aucun produit disponible',
              style: AppTextStyles.bodyMedium(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}
