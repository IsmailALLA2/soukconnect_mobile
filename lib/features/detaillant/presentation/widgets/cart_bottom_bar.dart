import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({
    super.key,
    required this.total,
    required this.notesController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final double total;
  final TextEditingController notesController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w, 12.h, 16.w, MediaQuery.paddingOf(context).bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(top: BorderSide(color: AppColors.grey200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: notesController,
            decoration: InputDecoration(
              hintText: 'Message pour le grossiste (optionnel)',
              hintStyle: AppTextStyles.bodyMedium(color: AppColors.grey400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              isDense: true,
            ),
            maxLines: 2,
            minLines: 1,
            style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Text(
                'Total: ',
                style: AppTextStyles.titleSmall(color: context.colorScheme.onSurface),
              ),
              Text(
                '${total.toStringAsFixed(2)} MAD',
                style: AppTextStyles.titleSmall(color: AppColors.primary),
              ),
              const Spacer(),
              FilledButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                child: isSubmitting
                    ? SizedBox(
                        width: 18.sp,
                        height: 18.sp,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text('Passer la commande'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
