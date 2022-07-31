import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splurge/charts/smoothing.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

/// Part of the interface for creating a [MyLineChart].
class Line {
  Line({
    required this.title,
    required this.color,
    required this.rawSpots,
    this.smoothing = const SmoothingParams(
      nDaySmoothing: 200,
      nEventSmoothing: 200,
    ),
  }) : assert(rawSpots.isNotEmpty);

  final String title;
  final Color color;
  final List<FlSpot> rawSpots;
  final SmoothingParams smoothing;

  late final List<FlSpot> spots = Smoothing(params: smoothing).smooth(rawSpots);
}

/// Creates a flexible-height "line chart" widget, including a title and legend.
/// This is meant to be a reusable wrapper around fl_chart that I could
/// potentially bring into future projects. Therefore, it should be kept free of
/// application-specific concepts or code-dependencies.
class MyLineChart extends StatelessWidget {
  const MyLineChart({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Title(title: title),
        _Legend(lines: lines),
        Expanded(child: _Chart(lines: lines)),
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
        titlesData: _titlesData(),
      ),
    );
  }

  FlTitlesData _titlesData() {
    return FlTitlesData(
      topTitles: AxisTitles(), // Hide for now
      rightTitles: AxisTitles(), // Hide for now
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => _xAxisDateLabels(meta, value),
        ),
      ),
    );
  }

  SideTitleWidget _xAxisDateLabels(TitleMeta meta, double value) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      angle: 25.degreesToRadians,
      child: Text(
        DateFormat.yMMMd().format(value.toDate),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title (text-based chart placeholder)',
      style: const TextStyle(fontSize: 24),
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
