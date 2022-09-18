import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class Smoothing {
  const Smoothing({required this.params});

  final SmoothingParams params;

  List<FlSpot> smooth(List<FlSpot> spots) => _smear(_nDayAvg(spots));

  List<FlSpot> _smear(List<FlSpot> spots) {
    assert(
      (params.nbrWeights.sum - 1).abs() < .0001,
      'Invalid nbrWeights: ${params.nbrWeights}',
    );
    final nbrLen = params.nbrWeights.length ~/ 2;

    final List<FlSpot> ret = [];
    for (int idx = nbrLen; idx < spots.length - nbrLen; idx++) {
      double acc = 0;
      for (int nbr = -nbrLen; nbr <= nbrLen; nbr++) {
        acc += spots[idx + nbr].y * params.nbrWeights[nbr + nbrLen];
      }
      ret.add(spots[idx].copyWith(y: acc));
    }

    return ret;
  }

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
    required this.nbrWeights,
  });

  final int nDaySmoothing;
  final List<double> nbrWeights;

  @override
  String toString() => 'smoothed over a $nDaySmoothing day std moving avg';
}
