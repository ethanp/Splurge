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
    return Card(
      margin: const EdgeInsets.all(32),
      color: Colors.black.withGreen(10).withRed(40).withBlue(30),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '   Income:    ${totalIncome.asCompactDollars()}',
              style: defaultFont.copyWith(color: Colors.green[400]),
              maxLines: 1,
            ),
            Text(
              '– Spending: ${totalSpending.asCompactDollars()}',
              style: defaultFont.copyWith(color: Colors.red),
              maxLines: 1,
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2),
              child: Container(
                height: 2,
                width: double.infinity,
                color: Colors.grey,
              ),
            ),
            Text(
              '   Savings:    ${(totalIncome - totalSpending).asCompactDollars()}',
              style: defaultFont.copyWith(color: Colors.blue[700]),
              maxLines: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
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
            ),
          ],
        ),
      ),
    );
  }

  static TextStyle get defaultFont => GoogleFonts.notoSerif(fontSize: 34);
}
