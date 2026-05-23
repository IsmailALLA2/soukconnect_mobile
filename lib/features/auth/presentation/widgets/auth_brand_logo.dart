import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

/// The SoukConnect brand logo block — green icon card + app name.
/// Used at the top of Login and Register pages.
class AuthBrandLogo extends StatelessWidget {
  const AuthBrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width:  72.w,
          height: 72.w,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color:      AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 24,
                offset:     const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.storefront_rounded,
            color: AppColors.white,
            size:  36.sp,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          'SoukConnect',
          style: AppTextStyles.headlineSmall(color: AppColors.primary),
        ),
      ],
    );
  }
}
