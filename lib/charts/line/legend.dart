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
      color: Colors.grey[800]!.withOpacity(.55),
      shape: Shape.roundedRect(circular: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            color: Colors.white.withOpacity(.7),
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

  Color _fade(Color? c) => c!.withOpacity(.7);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: _fade(Colors.black)),
        borderRadius: BorderRadius.circular(10),
        color: _fade(Colors.grey[900]),
      ),
      child: ListTile(
        leading: _coloredDash(),
        title: _lineTitle(),
        subtitle: _subtitle(),
      ),
    );
  }

  Widget _coloredDash() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: 30,
      height: 12,
      decoration: BoxDecoration(
        border: Border.all(color: _fade(Colors.black)),
        borderRadius: BorderRadius.circular(4),
        color: _fade(line.color),
      ),
    );
  }

  Widget _lineTitle() {
    return Text(
      line.title,
      style: GoogleFonts.kanit(
        color: _fade(line.color),
        fontWeight: FontWeight.w800,
        fontSize: 20,
      ),
    );
  }

  Widget _subtitle() {
    return Text(
      '${line.rawSpots.length} txns  |  ${line.smoothing}',
      style: GoogleFonts.heebo(
        fontStyle: FontStyle.italic,
        color: _fade(Colors.grey),
        fontSize: 13,
        fontWeight: FontWeight.w200,
      ),
    );
  }
}
