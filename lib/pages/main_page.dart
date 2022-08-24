import 'package:flutter/material.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/widgets/bar_charts.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/largest_transactions.dart';
import 'package:splurge/widgets/totals_card.dart';

class MainPage extends StatelessWidget {
  const MainPage(this.dataset);

  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(
          children: [
            TotalsCard(
              totalIncome: -dataset.incomeTxns.totalAmount,
              totalSpending: dataset.spendingTxns.totalAmount,
            ),
            Expanded(
              child: IncomeVsSpendingLineChart(
                fullDataset: dataset,
              ),
            ),
          ],
        ),
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
