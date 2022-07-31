import 'package:fl_chart/fl_chart.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

extension MBounds on Iterable<FlSpot> {
  double get minX => map((e) => e.x).min;

  double get maxX => map((e) => e.x).max;

  double get minY => map((e) => e.y).min;

  double get maxY => map((e) => e.y).max;
}

extension Bounds on LineChartBarData {
  double get minX => spots.where((e) => e != FlSpot.nullSpot).minX;

  double get maxX => spots.where((e) => e != FlSpot.nullSpot).maxX;

  double get minY => spots.where((e) => e != FlSpot.nullSpot).minY;

  double get maxY => spots.where((e) => e != FlSpot.nullSpot).maxY;
}

extension IBounds on Iterable<LineChartBarData> {
  double get minX => isEmpty ? 0 : map((e) => e.minX).min;

  double get maxX => isEmpty ? 0 : map((e) => e.maxX).max;

  double get minY => isEmpty ? 0 : map((e) => e.minY).min;

  double get maxY => isEmpty ? 0 : map((e) => e.maxY).max;
}

/// Define a constructor with named parameters. Ugh.
// ignore: non_constant_identifier_names
FlSpot Spot({required double x, required double y}) => FlSpot(x, y);
