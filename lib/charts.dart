import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions.dart';

class Line {
  Line({
    required this.title,
    required this.color,
    required this.spots,
  }) : assert(spots.isNotEmpty);

  final String title;
  final Color color;
  final List<FlSpot> spots;
}

class MyLineChart extends StatelessWidget {
  const MyLineChart({
    required this.title,
    required this.lines,
  });

  final String title;
  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title (text-based chart placeholder)',
          style: const TextStyle(fontSize: 24),
        ),
        ...lines.map<Widget>(
          (line) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${line.title}: ${line.spots.length} spots',
              style: TextStyle(
                color: line.color,
              ),
            ),
          ),
        ),
        Expanded(
          child: LineChart(LineChartData(
            minX: 0,
            maxX: 10,
            minY: 0,
            maxY: 10,
            titlesData: FlTitlesData(show: false),
            lineBarsData: lines.mapL(
              (line) => LineChartBarData(
                spots: line.spots,
                color: line.color,
              ),
            ),
          )),
        ),
      ],
    );
  }
}

class Bar {
  const Bar({required this.title, required this.value});

  final String title;
  final double value;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({required this.title, required this.bars});

  final String title;
  final List<Bar> bars;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$title (text-based chart placeholder)',
          style: const TextStyle(fontSize: 24),
        ),
        Text(
          bars
              .map((bar) => '${bar.title} ${bar.value.asCompactDollars()}')
              .join('\n'),
        ),
      ],
    );
  }
}
