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
      width: 420,
      child: Card(
        margin: const EdgeInsets.all(32),
        color: Colors.black.withGreen(10).withRed(40).withBlue(30),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textLine(
                prefix: '     Income:    ',
                color: Colors.green[400]!,
                amt: totalIncome,
              ),
              _textLine(
                prefix: '– Spending: ',
                color: Colors.red,
                amt: totalSpending,
              ),
              _dividerLine(),
              _textLine(
                prefix: '     Savings:    ',
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

  Text _textLine({
    required String prefix,
    required Color color,
    required double amt,
  }) {
    return Text(
      '$prefix${amt.asCompactDollars()}',
      style: defaultFont.copyWith(color: color),
      maxLines: 1,
    );
  }

  Widget _dividerLine() {
    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 2,
        left: 12,
        right: 28,
      ),
      child: Container(
        height: 3,
        width: 275,
        color: Colors.grey,
      ),
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
