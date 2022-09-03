import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

// TODO(feature): Improve this part. The smoothing is really not-great as-is.
class Smoothing {
  const Smoothing({required this.params});

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

    return lineBuilder.sublist(
      math.min(
        lineBuilder.length - 1,
        params.nDaySmoothing,
      ),
    );
  }
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

  @override
  String toString() =>
      'smoothed at $nDaySmoothing days, $nEventSmoothing events';
}
