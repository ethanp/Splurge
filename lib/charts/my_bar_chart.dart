import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

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
    return Column(
      children: [
        _title(),
        Expanded(child: _barChart()),
      ],
    );
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        barGroups: barGroups.mapL(
          (barGroup) => BarChartGroupData(
            x: 0,
            barRods: barGroup.bars.mapL(
              (bar) => BarChartRodData(
                toY: bar.value,
                color: bar.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return AutoSizeText(
      title,
      maxLines: 1,
      style: const TextStyle(fontSize: 24),
    );
  }
}
