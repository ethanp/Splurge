import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/charts/line/my_line_chart.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class IncomeVsSpendingLineChart extends ConsumerWidget {
  const IncomeVsSpendingLineChart({
    required this.incomeTxns,
    required this.spendingTxns,
  });

  final Dataset incomeTxns;
  final Dataset spendingTxns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedCategoriesProvider);
    final selectedCategories = ref.read(selectedCategoriesProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // TODO(feature): Show the category filter chips.
          Text('This is where the category filter chips will go'),
          Expanded(
            child: MyLineChart(
              title: 'Earning vs Spending',
              lines: [
                Line(
                  title: 'Earning',
                  color: Colors.green[800]!,
                  rawSpots: incomeTxns
                      .forCategories(selectedCategories)
                      .transactions
                      .mapL(
                        (txn) => Spot(
                          x: txn.date.toDouble,
                          // Make earning easier to compare with spending by inverting.
                          y: -txn.amount,
                        ),
                      ),
                ),
                Line(
                  title: 'Spending',
                  color: Colors.red,
                  rawSpots: spendingTxns
                      .forCategories(selectedCategories)
                      .transactions
                      .mapL(
                        (txn) => Spot(
                          x: txn.date.toDouble,
                          y: txn.amount,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
