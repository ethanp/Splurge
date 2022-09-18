import 'package:flutter/material.dart';
import 'package:splurge/global/style.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'line.dart';

class Legend extends StatelessWidget {
  const Legend({required this.lines});

  final List<Line> lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800]!.withOpacity(.7),
      shape: Shape.roundedRect(circular: 6),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                // TODO(UI): Make the [line.title] bold.
                '– ${line.title}: ${line.rawSpots.length} txns, ${line.smoothing}',
                style: appFont.copyWith(
                  color: line.color,
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
