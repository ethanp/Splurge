import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class BarGroup {
  const BarGroup({required this.title, required this.bars});

  final String title;
  final List<Bar> bars;
}

class Bar {
  const Bar({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final double value;
  final Color color;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({required this.title, required this.barGroups});

  final String title;
  final List<BarGroup> barGroups;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$title (text-based chart placeholder)',
          style: const TextStyle(fontSize: 24),
        ),
        // TODO(feature): Get the color right on each "bar" of text.
        Text(
          barGroups.map((barGroup) {
            final values = barGroup.bars
                .map((bar) => bar.value.asCompactDollars())
                .join(' ');
            return '${barGroup.title} $values';
          }).join('\n'),
        ),
      ],
    );
  }
}
