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
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall(
          color: _foregroundColor,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFF3E0);
      case OrderStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case OrderStatus.delivered:
        return const Color(0xFFE8F5E9);
      case OrderStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get _foregroundColor {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFE65100);
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return const Color(0xFFC62828);
    }
  }
}
