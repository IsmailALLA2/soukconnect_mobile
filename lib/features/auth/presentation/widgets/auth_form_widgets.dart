import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';

/// A small field label shown above each form input.
class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: AppTextStyles.labelMedium(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
}

/// A red banner displaying a global form/API error message.
/// Only render this when [message] is non-null.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color:        AppColors.errorLight,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// A full-width primary submit button with an integrated loading spinner.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String       label;
  final bool         isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:         AppColors.primary,
          foregroundColor:         AppColors.white,
          disabledBackgroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width:  22.w,
                height: 22.w,
                child: const GreenSpinner(size: 22, color: AppColors.white),
              )
            : Text(
                label,
                style: AppTextStyles.titleSmall(color: AppColors.white),
              ),
      ),
    );
  }
}

/// A horizontal "— ou —" divider.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'ou',
            style: AppTextStyles.bodySmall(color: AppColors.grey500),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
