import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/sizer.dart';
import '../../../features/detaillant/domain/entities/order_entity.dart'
    show OrderStatus;

class PieChartEntry {
  const PieChartEntry({required this.status, required this.count});

  final OrderStatus status;
  final int count;
}

class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.data,
  });

  final Map<OrderStatus, int> data;

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold<int>(0, (a, b) => a + b);

    return Column(
      children: [
        SizedBox(
          height: 200.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: _buildSections(),
                  centerSpaceRadius: 44.r,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {},
                    enabled: true,
                  ),
                ),
                duration: const Duration(milliseconds: 400),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total.toString(),
                    style: AppTextStyles.titleLarge(color: AppColors.grey900),
                  ),
                  Text(
                    'total',
                    style: AppTextStyles.labelSmall(color: AppColors.grey500),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ..._buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    if (data.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          color: AppColors.grey200,
          radius: 40,
          title: '',
        ),
      ];
    }

    return data.entries.map((entry) {
      final color = switch (entry.key) {
        OrderStatus.pending   => AppColors.pending,
        OrderStatus.confirmed => AppColors.confirmed,
        OrderStatus.cancelled => AppColors.cancelled,
        OrderStatus.delivered => AppColors.delivered,
      };
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: 48.r,
        title: '${entry.value}',
        titleStyle: AppTextStyles.labelSmall(color: AppColors.white),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  List<Widget> _buildLegend() {
    return data.entries.map((entry) {
      final color = switch (entry.key) {
        OrderStatus.pending   => AppColors.pending,
        OrderStatus.confirmed => AppColors.confirmed,
        OrderStatus.cancelled => AppColors.cancelled,
        OrderStatus.delivered => AppColors.delivered,
      };
      final label = switch (entry.key) {
        OrderStatus.pending   => 'En attente',
        OrderStatus.confirmed => 'Confirmée',
        OrderStatus.cancelled => 'Annulée',
        OrderStatus.delivered => 'Livrée',
      };

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: AppTextStyles.bodySmall(color: AppColors.grey700),
            ),
            SizedBox(width: 8.w),
            Text(
              '${entry.value}',
              style: AppTextStyles.labelSmall(color: AppColors.grey500),
            ),
          ],
        ),
      );
    }).toList();
  }
}
