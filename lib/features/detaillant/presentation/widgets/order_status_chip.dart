import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: _foregroundColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            status.label,
            style: AppTextStyles.labelSmall(color: _foregroundColor),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warningLight;
      case OrderStatus.confirmed:
        return AppColors.successLight;
      case OrderStatus.delivered:
        return AppColors.infoLight;
      case OrderStatus.cancelled:
        return AppColors.errorLight;
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.success;
      case OrderStatus.delivered:
        return AppColors.info;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }
}
