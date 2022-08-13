import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

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

class BarGroup {
  const BarGroup({
    required this.title,
    required this.bars,
  });

  final String title;
  final List<Bar> bars;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({
    required this.title,
    required this.barGroups,
  });

  final String title;
  final List<BarGroup> barGroups;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AutoSizeText(
        '$title (Bar Chart)',
        maxLines: 1,
        style: const TextStyle(fontSize: 24),
      ),
      // NB: Scrolling does work, you have to use the scroll-wheel, click and drag doesn't work on MacOS for ListView by default.
      Expanded(child: ListView(children: _bars())),
    ]);
  }

  List<Widget> _bars() {
    return barGroups.mapL(
      (barGroup) => Row(
        children: <Widget>[
          Text(
            barGroup.title,
            style: const TextStyle(color: Colors.black),
          ),
          ...barGroup.bars.mapL(
            (bar) => Text(
              bar.value.asCompactDollars(),
              style: TextStyle(color: bar.color),
            ),
          ),
        ].separatedBy(
          const SizedBox(width: 30),
        ),
      ),
    );
  }
}
