import 'package:flutter/material.dart';
import 'package:splurge/util/widgets.dart';

import 'line.dart';

class Legend extends StatelessWidget {
  const Legend({required this.title, required this.lines});

  final String title;
  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(title, style: titleStyle),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${line.title}: ${line.rawSpots.length} txns',
                  style: TextStyle(
                    color: line.color,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
