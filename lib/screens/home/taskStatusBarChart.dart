import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TaskStatusBarChart extends StatelessWidget {
  final int pendingTaskCount;
  final int inProgressTaskCount;
  final int completedTaskCount;

  TaskStatusBarChart({
    required this.pendingTaskCount,
    required this.inProgressTaskCount,
    required this.completedTaskCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: _generateBarGroups(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Pending');
                    case 1:
                      return Text('In Progress');
                    case 2:
                      return Text('Completed');
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(value.toString());
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: pendingTaskCount.toDouble(),
            color: Colors.blue,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: inProgressTaskCount.toDouble(),
            color: Colors.orange,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: completedTaskCount.toDouble(),
            color: Colors.green,
          ),
        ],
      ),
    ];
  }
}
