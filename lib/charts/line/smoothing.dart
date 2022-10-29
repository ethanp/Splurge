import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class Smoothing {
  const Smoothing({required this.params});

  final SmoothingParams params;

  List<FlSpot> smooth(List<FlSpot> spots) =>
      _smear(_chopEndsOff(_nDayAvg(spots)));

  /// Since it's ultimately distracting and too noisy to provide value.
  List<FlSpot> _chopEndsOff(List<FlSpot> spots) => spots.whereL((s) =>
      s.x.toDate.monthString != DateTime.now().monthString &&
      !s.x.toDate.isBefore(DateTime(2021)));

  /// The extent of smoothing is a function of the point's magnitude, since
  /// events like bonus payment, GSU cash-out, car purchase, need to be
  /// "smeared" *more*. Here, we smear down to a cap of "$20 of influence" per
  /// day.
  List<FlSpot> _smear(List<FlSpot> spots) {
    final List<double> ys = List.filled(spots.length, 0);
    for (final idx in spots.indices) {
      // ignore: prefer_const_declarations
      final double maxInfluence = 20;
      final int neighborhoodWidth = (spots[idx].y.abs() ~/ maxInfluence)
          .clamp(0, math.min(idx, spots.length - idx));
      final double scaled = spots[idx].y / (neighborhoodWidth * 2 + 1);
      for (int nbr = -neighborhoodWidth; nbr <= neighborhoodWidth; nbr++) {
        if (idx + nbr >= 0 && idx + nbr < spots.length) {
          ys[idx + nbr] += scaled;
        }
      }
    }
    return spots.mapWithIdx((spot, idx) => spot.copyWith(y: ys[idx])).toList();
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
  });

  final int nDaySmoothing;

  @override
  String toString() => 'over a $nDaySmoothing day std moving avg';
}
