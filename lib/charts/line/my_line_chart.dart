import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/charts/line/smoothing.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/widgets.dart';

/// Part of the interface for creating a [MyLineChart].
class Line {
  Line({
    required this.title,
    required this.color,
    required this.rawSpots,
    this.smoothing = const SmoothingParams(
      nDaySmoothing: 110,
      nEventSmoothing: 2,
    ),
  }) : assert(rawSpots.isNotEmpty);

  final String title;
  final Color color;
  final List<FlSpot> rawSpots;
  final SmoothingParams smoothing;

  late final List<FlSpot> spots = Smoothing(params: smoothing).smooth(rawSpots);
}

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
        Text(title, style: titleStyle),
        Positioned(top: 50, child: _Legend(lines: lines)),
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

        // Hide datapoints. Default dot is too big.
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
        minY: flLines.minY - verticalMargin,
        maxY: flLines.maxY + verticalMargin,
        titlesData: _axisLabels(),
        lineTouchData: _tooltip(),
      ),
    );
  }

  LineTouchData _tooltip() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: Colors.grey[900],
        maxContentWidth: 200, // default is 120.
        getTooltipItems: (touchedSpots) {
          return touchedSpots.mapWithIdx((touchedSpot, _) {
            final line = lines[touchedSpot.barIndex];
            return LineTooltipItem(
              '${line.title}: ${touchedSpot.y.asCompactDollars()}',
              TextStyle(color: line.color),
              // Chart library dictates that #tooltip_items == #touched_spots,
              //  so to show the date as a separate line, we append it to the
              //  last tooltip.
              children: [
                if (touchedSpot == touchedSpots.last) // yes it's equatable.
                  TextSpan(
                    text: '\nDate: ${touchedSpots.first.x.toDate.formatted}',
                    style: const TextStyle(color: Colors.white60),
                  ),
              ],
            );
          }).toList();
        },
      ),
    );
  }

  FlTitlesData _axisLabels() {
    return FlTitlesData(
      topTitles: AxisTitles(), // Hide for now
      bottomTitles: _dateAxisLabels(),
      leftTitles: _leftAxisLabels(),
      rightTitles: AxisTitles(), // Hide for now
    );
  }

  AxisTitles _leftAxisLabels() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 100,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          space: 0,
          axisSide: meta.axisSide,
          child: Text(
            value.asCompactDollars(),
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  AxisTitles _dateAxisLabels() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          angle: 25.degreesToRadians,
          child: Text(
            value.toDate.monthString,
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.lines});

  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lines.mapL(
        (line) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '${line.title}: ${line.rawSpots.length} txns',
            style: TextStyle(
              color: line.color,
            ),
          ),
        ),
      ),
    );
  }
}
