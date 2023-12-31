import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'axis_labels.dart';
import 'legend.dart';
import 'line.dart';
import 'tooltip.dart';

/// Creates a flexible-height "line chart" widget, including a title and legend.
/// It should be kept free of application-specific concepts or
/// code-dependencies.
class MyLineChart extends ConsumerWidget {
  const MyLineChart({
    this.minX,
    this.maxX,
    required this.lines,
  });

  final double? minX;
  final double? maxX;
  final List<Line> lines;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 4, right: 4),
      child: Stack(
        children: [
          _chart(ref),
          Positioned(left: 50, top: 12, child: Legend(lines: lines)),
        ],
      ),
    );
  }

  Widget _chart(WidgetRef ref) {
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
        minX: minX ?? flLines.minX - horizontalMargin,
        maxX: maxX ?? flLines.maxX + horizontalMargin,
        minY: 0, // flLines.minY - verticalMargin,
        maxY: flLines.maxY + verticalMargin,
        titlesData: AxisLabels.create(),
        lineTouchData: MyTooltip.create(
          lines,
          ref.watch(DatasetNotifier.filteredProvider),
        ),
      ),
    );
  }
}
