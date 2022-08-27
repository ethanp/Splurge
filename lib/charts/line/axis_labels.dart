import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class AxisLabels {
  static FlTitlesData create() {
    return FlTitlesData(
      topTitles: AxisTitles(), // Hide for now
      bottomTitles: _dateAxisLabels(),
      leftTitles: _leftAxisLabels(),
      rightTitles: AxisTitles(), // Hide for now
    );
  }

  static AxisTitles _leftAxisLabels() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        interval: 100,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          space: 0,
          axisSide: meta.axisSide,
          child: Text(
            value.asCompactDollars(),
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }

  static AxisTitles _dateAxisLabels() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          angle: 25.degreesToRadians,
          child: Text(
            value.toDate.monthString,
            style: TextStyle(fontSize: 11),
          ),
        ),
      ),
    );
  }
}
