import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions.dart';

class Line {
  const Line({
    required this.title,
    required this.spots,
  });

  final String title;
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
    return Container();
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
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          Text(bars
              .map((bar) => '${bar.title} ${bar.value.asCompactDollars()}')
              .join('\n')),
        ],
      ),
    );
  }
}
