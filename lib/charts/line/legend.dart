import 'package:flutter/material.dart';

import 'line.dart';

class Legend extends StatelessWidget {
  const Legend({required this.lines});

  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800]!.withOpacity(.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${line.title}: ${line.rawSpots.length} txns, ${line.smoothing}',
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
