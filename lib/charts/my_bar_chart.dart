import 'package:auto_size_text/auto_size_text.dart';
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
    return Column(children: [
      AutoSizeText(
        '$title (text-based chart placeholder)',
        maxLines: 1,
        style: const TextStyle(fontSize: 24),
      ),
      Expanded(
        // TODO(bug): Why isn't this ListView scrollable?
        child: ListView(
          shrinkWrap: true, // required when height is unbounded.
          children: barGroups.mapL(
            (barGroup) => Row(
              children: <Widget>[
                Text(
                  barGroup.title,
                  style: TextStyle(color: Colors.black),
                ),
                ...barGroup.bars.mapL(
                  (bar) => Text(
                    bar.value.asCompactDollars(),
                    style: TextStyle(color: bar.color),
                  ),
                ),
              ].separatedBy(const SizedBox(width: 30)),
            ),
          ),
        ),
      ),
    ]);
  }
}
