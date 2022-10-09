import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_LegendTitle(), ...lines.mapL(_LineLegend.new)],
        ),
      ),
    );
  }
}

class _LegendTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Legend',
          style: GoogleFonts.josefinSans(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

class _LineLegend extends StatelessWidget {
  const _LineLegend(this.line);

  final Line line;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[900],
      ),
      child: ListTile(
        leading: Container(
          margin: const EdgeInsets.only(top: 10),
          width: 40,
          height: 16,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(4),
            color: line.color,
          ),
        ),
        title: Text(
          line.title,
          style: GoogleFonts.kanit(
            color: line.color,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        subtitle: Text(
          '${line.smoothing}',
          style: GoogleFonts.heebo(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w200,
          ),
        ),
        trailing: Text('${line.rawSpots.length} txns'),
      ),
    );
  }
}
