import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 성과 차트 위젯
/// 운동 진행상황을 시각적으로 표시
class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String? title;
  final Color? primaryColor;

  const PerformanceChart({
    super.key,
    required this.data,
    this.title,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chartColor = primaryColor ?? colorScheme.primary;

    return Column(
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
        ],
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withValues(alpha: 0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < data.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            data[index]['week'] ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '${value.toInt()}%',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: (data.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final value = entry.value['progress'] ?? 0;
                    return FlSpot(index.toDouble(), value.toDouble());
                  }).toList(),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      chartColor.withValues(alpha: 0.8),
                      chartColor,
                    ],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: chartColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        chartColor.withValues(alpha: 0.3),
                        chartColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => colorScheme.surfaceContainerHighest,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final flSpot = barSpot;
                      final index = flSpot.x.toInt();
                      final week = data[index]['week'] ?? '';
                      final progress = flSpot.y.toInt();
                      
                      return LineTooltipItem(
                        '$week\n$progress% 달성',
                        TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}