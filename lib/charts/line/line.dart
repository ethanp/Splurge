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
    this.smoothing = const SmoothingParams(nDaySmoothing: 99, nbrWeights: [
      .05,
      .05,
      .05,
      .05,
      .1,
      .1,
      .2,
      .1,
      .1,
      .05,
      .05,
      .05,
      .05,
    ]),
  })  : assert(rawSpots.isNotEmpty, 'fl_chart does not allow empty lines'),
        spots = Smoothing(params: smoothing).smooth(rawSpots);

  final String title;
  final Color color;
  final List<FlSpot> rawSpots;
  final SmoothingParams smoothing;

  final List<FlSpot> spots;
}
