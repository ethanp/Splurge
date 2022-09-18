import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/util/providers.dart';
import 'package:splurge/widgets/bar_charts.dart';
import 'package:splurge/widgets/filter_card.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/totals_card.dart';
import 'package:splurge/widgets/transactions_review.dart';

class MainPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(DatasetNotifier.filteredProvider);

    return Row(children: [
      Expanded(
        child: Column(children: [
          Row(children: [
            TotalsCard(
              totalIncome: -dataset.incomeTxns.totalAmount,
              totalSpending: dataset.spendingTxns.totalAmount,
            ),
            FilterCard(),
          ]),
          Expanded(child: IncomeVsSpendingLineChart()),
        ]),
      ),
      Expanded(
        child: Column(children: [
          Expanded(child: BarCharts(dataset: dataset)),
          Expanded(child: LargestTransactions(dataset: dataset)),
        ]),
      ),
    ]);
  }
}
