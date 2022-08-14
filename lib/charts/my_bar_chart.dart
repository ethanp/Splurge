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
      AutoSizeText(title, maxLines: 1, style: titleStyle),
      // Expanded(child: _barChart()),
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

  // TODO(bug): Somehow this isn't loading properly right now.
  //  Seems to be freezing the app or something.
  FlTitlesData _axisLabels() {
    return FlTitlesData(
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              '$value',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            child: Text('Q3 2022'),
            axisSide: meta.axisSide,
          ),
        ),
      ),
    );
  }
}
