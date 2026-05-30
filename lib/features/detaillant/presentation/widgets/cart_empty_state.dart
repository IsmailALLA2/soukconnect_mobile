import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64.sp, color: AppColors.grey400),
          SizedBox(height: 16.h),
          Text(
            'Votre panier est vide',
            style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ajoutez des produits depuis une boutique',
            style: AppTextStyles.bodyMedium(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
