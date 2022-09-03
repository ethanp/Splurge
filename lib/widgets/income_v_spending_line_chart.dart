import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/charts/line/line.dart';
import 'package:splurge/charts/line/my_line_chart.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class IncomeVsSpendingLineChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(SelectedCategories.provider);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);
    final dataset = ref.read(DatasetNotifier.filteredProvider);

    // Make earning easier to compare with spending by inverting.
    final incomeSpots = dataset.incomeTxns.transactions
        .mapL((txn) => Spot(x: txn.date.toDouble, y: -txn.amount));

    final spendingSpots = dataset.spendingTxns.transactions
        .mapL((txn) => Spot(x: txn.date.toDouble, y: txn.amount));

    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 18, right: 16),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 18),
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
            ),
          ],
        ),
      ),
    );
  }
}
