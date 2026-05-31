import 'package:flutter/material.dart';

import '../../../../core/animations/app_animations.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class IncomingOrderEmptyState extends StatelessWidget {
  const IncomingOrderEmptyState({super.key});

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
                  gradient: AppGradients.infoBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 44,
                  color: AppColors.info,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Aucune commande pour le moment',
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
                'Partagez votre boutique pour recevoir\ndes commandes de vos clients.',
                style: AppTextStyles.bodyMedium(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 28.h),
            AppAnimations.fadeSlideIn(
              delay: const Duration(milliseconds: 500),
              child: OutlinedButton.icon(
                onPressed: () {}, // UI only for now
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text('Partager ma boutique'),
                style: OutlinedButton.styleFrom(
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
