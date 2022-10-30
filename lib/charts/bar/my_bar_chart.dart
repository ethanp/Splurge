import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/global/style.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'axis_labels.dart';

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
    required this.xValue,
    required this.bars,
  });

  final int xValue;
  final List<Bar> bars;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({
    required this.title,
    required this.xTitle,
    required this.barGroups,
  });

  final String title;
  final String Function(double) xTitle;
  final List<BarGroup> barGroups;

  @override
  Widget build(BuildContext context) {
    if (barGroups.isEmpty) {
      return Center(
        child: Text(
          'This bar-chart has no data to show (barGroups.isEmpty)',
          style: titleStyle,
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 12),
          child: AutoSizeText(title, maxLines: 1, style: titleStyle),
        ),
        Expanded(child: _barChart()),
      ],
    );
  }

  Widget _barChart() {
    return BarChart(
      BarChartData(
        barGroups: _formatData(),
        titlesData: AxisLabels.create(xTitle),
        barTouchData: _tooltip(),
      ),
    );
  }

  BarTouchData _tooltip() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.grey[900],
        maxContentWidth: 200, // default is 120
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            rod.toY.asCompactDollars(),
            TextStyle(color: rod.color),
            children: [
              TextSpan(
                // ignore: prefer_interpolation_to_compose_strings
                text: '\n' + group.x.toDouble().toDate.monthString,
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          );
        },
      ),
    );
  }

  List<BarChartGroupData> _formatData() {
    return barGroups.mapL(
      (barGroup) => BarChartGroupData(
        x: barGroup.xValue,
        barRods: barGroup.bars.mapL(
          (bar) => BarChartRodData(
            toY: bar.value,
            color: bar.color,
          ),
        ),
      ),
    );
  }
}
