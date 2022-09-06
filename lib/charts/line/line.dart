import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'my_line_chart.dart';
import 'smoothing.dart';

/// Part of the interface for creating a [MyLineChart].
class Line {
  Line({
    required this.title,
    required this.color,
    required this.rawSpots,
    // TODO(feature): Make params adjustable via slider, and available globally
    //  via Riverpod. Create a [SmoothingParamsWidget] to handle the UI, which
    //  will evolve along with the params object itself as the smoothness
    //  library (hopefully) improves over time.
    this.smoothing = const SmoothingParams(nDaySmoothing: 99),
  })  : assert(rawSpots.isNotEmpty, 'fl_chart does not allow empty lines'),
        spots = Smoothing(params: smoothing).smooth(rawSpots);

  final String title;
  final Color color;
  final List<FlSpot> rawSpots;
  final SmoothingParams smoothing;

  final List<FlSpot> spots;
}
