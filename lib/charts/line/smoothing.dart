import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

// TODO(feature): Improve this part. The smoothing is really not-great as-is.
//  One idea is to "back-propagate" txns so they have a "bell curve"-shaped
//  effect on the avg. Should be *relatively* easy to implement, and it visually
//  should make even more sense the current smoothing system. And as long as the
//  "area under the curve" = 1, then I don't think it's going to bias the final
//  number in a bad way, like the event avg was doing before.
class Smoothing {
  const Smoothing({required this.params});

  final SmoothingParams params;

  List<FlSpot> smooth(List<FlSpot> spots) => _nDayAvg(spots);

  /// Daily, output a point that represents the average of all sessions from
  /// within the preceding [SmoothingParams.nDaySmoothing] days.
  List<FlSpot> _nDayAvg(List<FlSpot> spots) {
    if (spots.isEmpty || params.nDaySmoothing < 2) return spots;

    /// Points to the last session before currDate.
    int lastValidIdx = 0;

    var currDate = spots.first.x.toDate;

    /// Finds the average for all sessions within preceding [avgPeriod] duration.
    double periodAvg() {
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
      lineBuilder.add(FlSpot(currDate.toDouble, periodAvg()));
      currDate = currDate.add(const Duration(days: 1));
    }
    // Add one last day.
    lineBuilder.add(FlSpot(currDate.toDouble, periodAvg()));

    // Cut off the initial ramp-up days for cleanliness.
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
  });

  final int nDaySmoothing;

  @override
  String toString() => 'smoothed over a $nDaySmoothing day std moving avg';
}
