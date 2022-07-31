import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

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
