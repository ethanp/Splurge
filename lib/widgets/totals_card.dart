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
          children: [
            AutoSizeText(
              'Total income ever: ${totalIncome.asCompactDollars()}',
              maxLines: 2,
              style: TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 20),
            AutoSizeText(
              'Total spending ever: ${totalSpending.asCompactDollars()}',
              maxLines: 2,
              style: TextStyle(fontSize: 44),
            ),
          ],
        ),
      ),
    );
  }
}
