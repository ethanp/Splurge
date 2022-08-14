import 'package:flutter/material.dart';
import 'package:splurge/copilot_parser.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/widgets.dart';
import 'package:splurge/widgets/bar_charts.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/largest_transactions.dart';
import 'package:splurge/widgets/totals_card.dart';

void main() => runApp(AppWidget());

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal[800],
          title: Text('Personal finances analyzer'),
        ),
        body: Center(
          child: LoadThenShow(
            future: CopilotExportReader.loadData,
            widgetBuilder: AppContents.new,
          ),
        ),
      ),
    );
  }
}

class AppContents extends StatelessWidget {
  const AppContents(this.dataset);

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
                incomeTxns: dataset.incomeTxns,
                spendingTxns: dataset.spendingTxns,
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
