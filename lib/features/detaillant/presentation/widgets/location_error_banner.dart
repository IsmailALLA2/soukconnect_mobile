import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LocationErrorBanner
// Amber warning strip shown when GPS permission is denied or services are off.
// ─────────────────────────────────────────────────────────────────────────────

class LocationErrorBanner extends StatelessWidget {
  const LocationErrorBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String       message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off_rounded,
              color: AppColors.warning,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall(color: AppColors.warning),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                minimumSize: Size.zero,
              ),
              child: Text(
                'Réessayer',
                style: AppTextStyles.labelSmall(color: AppColors.warning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
