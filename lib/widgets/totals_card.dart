import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.all(50),
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              'Income: ${totalIncome.asCompactDollars()}',
              style: TextStyle(fontSize: 44, color: Colors.green[700]),
              maxLines: 1,
            ),
            AutoSizeText(
              'Spending: ${totalSpending.asCompactDollars()}',
              style: TextStyle(fontSize: 44, color: Colors.red),
              maxLines: 1,
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 2),
              child: Container(
                width: double.infinity,
                height: 2,
                color: Colors.black,
              ),
            ),
            AutoSizeText(
              'Savings: ${(totalIncome - totalSpending).asCompactDollars()}',
              style: TextStyle(fontSize: 44),
              maxLines: 1,
            ),
            AutoSizeText('Since December 2020'),
          ],
        ),
      ),
    );
  }
}
