import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

import 'axis_labels.dart';
import 'legend.dart';
import 'line.dart';
import 'tooltip.dart';

/// Creates a flexible-height "line chart" widget, including a title and legend.
/// It should be kept free of application-specific concepts or
/// code-dependencies.
class MyLineChart extends StatelessWidget {
  const MyLineChart({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
            left: 80, top: 20, child: Legend(title: title, lines: lines)),
        _Chart(lines: lines),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.lines});

  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    final List<LineChartBarData> flLines = lines.mapL(
      (line) => LineChartBarData(
        spots: line.spots,
        color: line.color,

        // Looks better with individual data-dots hidden.
        dotData: FlDotData(show: false),
      ),
    );

    // Margin between the end of the axis and the most-extreme points.
    final verticalMargin = (flLines.maxY - flLines.minY) * .02;
    final horizontalMargin = (flLines.maxX - flLines.minX) * .02;

    return LineChart(
      // Parameter Docs:
      // https://github.com/imaNNeoFighT/fl_chart/blob/master/repo_files/documentations/line_chart.md
      LineChartData(
        lineBarsData: flLines,
        minX: flLines.minX - horizontalMargin,
        maxX: flLines.maxX + horizontalMargin,
        minY: 0, // flLines.minY - verticalMargin,
        maxY: flLines.maxY + verticalMargin,
        titlesData: AxisLabels.create(),
        lineTouchData: MyTooltip.create(lines),
      ),
    );
  }
}
