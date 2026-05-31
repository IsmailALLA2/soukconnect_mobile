import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/sizer.dart';

class RevenueLineChart extends StatelessWidget {
  const RevenueLineChart({
    super.key,
    required this.spots,
    required this.maxY,
  });

  final List<FlSpot> spots;
  final double maxY;

  static const _dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY * 1.15,
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
              reservedSize: 40.w,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox.shrink();
                final v = value >= 1000
                    ? '${(value / 1000).toStringAsFixed(0)}k'
                    : value.toInt().toString();
                return Text(
                  '$v MAD',
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
                return Text(
                  _dayLabels[i],
                  style: AppTextStyles.labelSmall(color: AppColors.grey500),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.35),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.grey900,
            tooltipRoundedRadius: 8.r,
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final v = spot.y.toStringAsFixed(0);
              return LineTooltipItem(
                '$v MAD',
                TextStyle(
                  color: AppColors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),
      ),
      duration: const Duration(milliseconds: 400),
    );
  }
}
