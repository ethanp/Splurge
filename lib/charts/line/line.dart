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
    // TODO(UX): Show the current smoothing params in the legend or something.
    //  It will make the graph easier to interpret.
    this.smoothing = const SmoothingParams(
      nDaySmoothing: 110,
      nEventSmoothing: 2,
    ),
  }) : assert(rawSpots.isNotEmpty, 'fl_chart does not allow empty lines');

  final String title;
  final Color color;
  final List<FlSpot> rawSpots;
  final SmoothingParams smoothing;

  late final List<FlSpot> spots = Smoothing(params: smoothing).smooth(rawSpots);
}
