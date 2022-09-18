import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/charts/line/line.dart';
import 'package:splurge/charts/line/my_line_chart.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class IncomeVsSpendingLineChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(DatasetNotifier.filteredProvider);

    // Make earning easier to compare with spending by inverting.
    final incomeSpots = dataset.incomeTxns.txns
        .mapL((txn) => Spot(x: txn.date.toDouble, y: -txn.amount));

    final spendingSpots = dataset.spendingTxns.txns
        .mapL((txn) => Spot(x: txn.date.toDouble, y: txn.amount));

    return Card(
      margin: const EdgeInsets.all(12),
      shape: Shape.roundedRect(circular: 10),
      elevation: 8,
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.only(left: 4, top: 12, right: 20, bottom: 20),
        child: MyLineChart(
          title: 'Earning vs Spending',
          lines: [
            if (incomeSpots.isNotEmpty)
              Line(
                title: 'Earning',
                color: Colors.green[800]!,
                rawSpots: incomeSpots,
              ),
            if (spendingSpots.isNotEmpty)
              Line(
                title: 'Spending',
                color: Colors.red,
                rawSpots: spendingSpots,
              ),
          ],
        ),
      ),
    );
  }
}
