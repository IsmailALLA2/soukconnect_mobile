import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import 'store_form_sheet.dart';

class StoreEmptyState extends StatelessWidget {
  const StoreEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store_mall_directory_outlined,
                size: 44.sp,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              "Vous n'avez pas encore de boutique",
              style: AppTextStyles.titleSmall(
                color: Theme.of(context).colorScheme.onSurface,
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
