import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class AxisLabels {
  static FlTitlesData create(String Function(double) xTitle) {
    return FlTitlesData(
      topTitles: _none(),
      leftTitles: _sideTitles(),
      rightTitles: _sideTitles(reverse: true),
      bottomTitles: _bottomTitles(xTitle),
    );
  }

  static AxisTitles _none() =>
      AxisTitles(sideTitles: SideTitles(showTitles: false));

  static AxisTitles _sideTitles({bool reverse = false}) {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 58,
        interval: 40000,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          space: 0,
          axisSide: meta.axisSide,
          angle: (reverse ? 45 : -45).degreesToRadians,
          child: Text(
            value.asCompactDollars(),
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  static AxisTitles _bottomTitles(String Function(double) xTitle) {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          angle: 40.degreesToRadians,
          child: Text(
            xTitle(value),
            style: TextStyle(fontSize: 10),
          ),
        ),
      ),
    );
  }
}
