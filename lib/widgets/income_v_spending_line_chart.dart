import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/charts/line/my_line_chart.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class IncomeVsSpendingLineChart extends ConsumerWidget {
  const IncomeVsSpendingLineChart({required this.fullDataset});

  final Dataset fullDataset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedCategoriesProvider);
    final selectedCategories = ref.read(selectedCategoriesProvider.notifier);
    final incomeSpots = fullDataset.incomeTxns
        .forCategories(selectedCategories)
        .transactions
        .mapL(
          (txn) => Spot(
            x: txn.date.toDouble,
            // Make earning easier to compare with spending by inverting.
            y: -txn.amount,
          ),
        );
    final spendingSpots = fullDataset.spendingTxns
        .forCategories(selectedCategories)
        .transactions
        .mapL(
          (txn) => Spot(
            x: txn.date.toDouble,
            y: txn.amount,
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _categoryChips(selectedCategories),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _categoryChips(SelectedCategories selectedCategories) {
    final categoryNames =
        fullDataset.transactions.map((txn) => txn.category).toSet();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final categoryName in categoryNames)
          FilterChip(
            selectedColor: Colors.orange[900],
            label: Text(categoryName),
            selected: selectedCategories.contains(categoryName),
            onSelected: (bool? isSelected) {
              print(categoryName + ' ' + isSelected.toString());
              if (isSelected ?? false)
                selectedCategories.add(categoryName);
              else
                selectedCategories.remove(categoryName);
            },
          ),
      ],
    );
  }
}
