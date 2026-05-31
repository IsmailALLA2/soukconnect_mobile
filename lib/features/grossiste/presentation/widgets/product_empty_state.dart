import 'package:flutter/material.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/gradient_card.dart';

class ProductEmptyState extends StatelessWidget {
  const ProductEmptyState({super.key, this.onAddProduct});

  final VoidCallback? onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAnimations.pulse(
              child: Container(
                width: 96.w,
                height: 96.w,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryDiagonal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Votre catalogue est vide',
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
                'Ajoutez vos produits pour commencer\nà vendre sur SoukConnect.',
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28.h),
            if (onAddProduct != null)
              AppAnimations.fadeSlideIn(
                delay: const Duration(milliseconds: 500),
                child: GradientCard(
                  gradient: AppGradients.primaryDiagonal,
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                  borderRadius: 12,
                  onTap: onAddProduct,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: AppColors.white, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        'Ajouter un produit',
                        style: AppTextStyles.labelLarge(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
