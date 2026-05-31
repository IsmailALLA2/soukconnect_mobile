import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/sizer.dart';

class OrdersBarChart extends StatelessWidget {
  const OrdersBarChart({
    super.key,
    required this.barGroups,
  });

  final List<BarChartGroupData> barGroups;

  static const _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _computeMaxY() * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.grey300,
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.w,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.labelSmall(color: AppColors.grey500),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24.h,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= _dayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    _dayLabels[i],
                    style: AppTextStyles.labelSmall(color: AppColors.grey500),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: barGroups,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.grey900,
            tooltipRoundedRadius: 8.r,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  double _computeMaxY() {
    double max = 0;
    for (final group in barGroups) {
      for (final rod in group.barRods) {
        if (rod.toY > max) max = rod.toY;
      }
    }
    return max;
  }
}
