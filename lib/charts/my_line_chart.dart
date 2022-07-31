import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

  late final List<FlSpot> spots =
      _Smoothing(params: smoothing).smooth(rawSpots);
}

class SmoothingParams {
  const SmoothingParams({
    required this.nDaySmoothing,
    required this.nEventSmoothing,
  });

  final int nDaySmoothing;

  /// In some cases the only reason this is useful is because it makes the line
  /// more pretty when combined with the nDay smoothing, but there may be no
  /// "n-event cycles" in the data that have to be smoothed.
  final int nEventSmoothing;
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
        minX: flLines.minX - horizontalMargin,
        maxX: flLines.maxX + horizontalMargin,
        minY: flLines.minY - verticalMargin,
        maxY: flLines.maxY + verticalMargin,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(), // Hide for now
          rightTitles: AxisTitles(), // Hide for now
        ),
        lineBarsData: flLines,
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

class _Smoothing {
  const _Smoothing({required this.params});

  final SmoothingParams params;

  List<FlSpot> smooth(List<FlSpot> spots) => _nDayAvg(_nEventAvg(spots));

  /// Represent each point of a new line as the avg of the last
  /// [SmoothingParams.nEventSmoothing] points of this line's [spots].
  List<FlSpot> _nEventAvg(List<FlSpot> spots) {
    if (spots.isEmpty || params.nEventSmoothing < 2) return spots;

    return spots.mapWithIdx(
      (spot, lastIdx) => Spot(
        x: spot.x,
        y: spots
            .sublist(
              (lastIdx - params.nEventSmoothing).mustBeAtLeast(0),
              lastIdx + 1, // ending is exclusive (I double-checked).
            )
            .avgBy((s) => s.y),
      ),
    );
  }

  /// Daily, output a point that represents the average of all sessions from
  /// within the preceding [SmoothingParams.nDaySmoothing] days.
  List<FlSpot> _nDayAvg(List<FlSpot> spots) {
    if (spots.isEmpty || params.nDaySmoothing < 2) return spots;

    /// Points to the last session before currDate.
    int lastValidIdx = 0;

    var currDate = spots.first.x.toDate;

    /// Finds the average for all sessions within preceding [avgPeriod] duration.
    double _periodAvg() {
      /// Find the last valid idx before currDate.
      while (lastValidIdx + 1 < spots.length &&
          currDate.isAfter(spots[lastValidIdx + 1].x.toDate)) {
        lastValidIdx++;
      }

      // Add up the relevant totals by walking backwards through the raw data
      // until we go outside the valid date-range.
      double sum = 0.0;
      var backwardScanner = lastValidIdx;
      final lowerBoundDate =
          currDate.subtract(Duration(days: params.nDaySmoothing));
      while (backwardScanner >= 0 &&
          lowerBoundDate.isBefore(spots[backwardScanner].x.toDate)) {
        sum += spots[backwardScanner--].y;
      }

      final numDaysAveragedTogether = math.min(
        params.nDaySmoothing,
        currDate.difference(spots.first.x.toDate).inDays + 1.5,
      );
      // Divide by the length of the date-range we summed-up.
      return sum / numDaysAveragedTogether;
    }

    // Add a point for every day from start to finish.
    final lineBuilder = <FlSpot>[];
    while (currDate.isBefore(spots.last.x.toDate)) {
      lineBuilder.add(FlSpot(currDate.toDouble, _periodAvg()));
      currDate = currDate.add(const Duration(days: 1));
    }
    // Add one last day.
    lineBuilder.add(FlSpot(currDate.toDouble, _periodAvg()));

    return lineBuilder;
  }
}
