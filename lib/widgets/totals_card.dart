import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../util/extensions/framework_extensions.dart';

class TotalsCard extends StatelessWidget {
  const TotalsCard({
    required this.totalIncome,
    required this.totalSpending,
  });

  final double totalIncome;
  final double totalSpending;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 440,
      child: Card(
        margin: const EdgeInsets.all(32),
        shape: Shape.roundedRect(circular: 20),
        color: Colors.black.withGreen(10).withRed(40).withBlue(30),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textLine(
                prefix: '     Income:      ',
                color: Colors.green[400]!,
                amt: totalIncome,
              ),
              _textLine(
                prefix: '– Spending:   ',
                color: Colors.red,
                amt: totalSpending,
              ),
              _dividerLine(),
              _textLine(
                prefix: '     Savings:      ',
                color: Colors.blue[700]!,
                amt: totalIncome - totalSpending,
              ),
              _dateBound(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textLine({
    required String prefix,
    required Color color,
    required double amt,
  }) {
    // Give room for the negative sign.
    if (amt < 0) prefix = prefix.substring(0, prefix.length - 3);
    return AutoSizeText(
      '$prefix${amt.asCompactDollars()}',
      style: defaultFont.copyWith(color: color),
      maxLines: 1,
    );
  }

  Widget _dividerLine() {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 2,
        left: 12,
        right: 28,
      ),
      height: 3,
      color: Colors.grey,
    );
  }

  Widget _dateBound() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: AutoSizeText(
          'Since December 2020',
          textAlign: TextAlign.right,
          style: defaultFont.copyWith(
            fontSize: 12,
            color: Colors.blueGrey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  static TextStyle get defaultFont => GoogleFonts.merriweather(fontSize: 30);
}
