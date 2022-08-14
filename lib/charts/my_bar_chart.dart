import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/widgets.dart';

class Bar {
  const Bar({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;
}

class BarGroup {
  const BarGroup({
    required this.title,
    required this.bars,
  });

  final String title;
  final List<Bar> bars;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({
    required this.title,
    required this.barGroups,
  });

  final String title;
  final List<BarGroup> barGroups;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 12),
        child: AutoSizeText(title, maxLines: 1, style: titleStyle),
      ),
      Expanded(child: _barChart()),
    ]);
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        barGroups: _formatData(),
        titlesData: _axisLabels(),
      ),
    );
  }

  List<BarChartGroupData> _formatData() {
    return barGroups.mapL(
      (barGroup) => BarChartGroupData(
        x: 0,
        barRods: barGroup.bars.mapL(
          (bar) => BarChartRodData(
            toY: bar.value,
            color: bar.color,
          ),
        ),
      ),
    );
  }

  FlTitlesData _axisLabels() {
    return FlTitlesData(
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 58,
          interval: 40000,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            space: 0,
            axisSide: meta.axisSide,
            angle: -45.degreesToRadians,
            child: Text(
              '${value.asCompactDollars()}',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 58,
          interval: 40000,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            space: 0,
            axisSide: meta.axisSide,
            angle: 45.degreesToRadians,
            child: Text(
              '${value.asCompactDollars()}',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            angle: 40.degreesToRadians,
            child: Text(
              'Q3 2022',
              style: TextStyle(fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }
}
