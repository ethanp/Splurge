import 'package:flutter/material.dart';
import 'package:splurge/charts.dart';
import 'package:splurge/copilot_parser.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/widgets.dart';

void main() => runApp(AppWidget());

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Personal finances analyzer')),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _totalsCard(),
              Expanded(child: _lineChart()),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _monthlyBarChart()),
              Expanded(child: _quarterlyBarChart()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _monthlyBarChart() {
    return MyBarChart(
      title: 'Spending by month',
      bars: dataset.spendingTxns.txnsByMonth.mapL(
        (Dataset month) => Bar(
          title: month.transactions.first.date.monthString,
          value: month.totalAmount,
        ),
      ),
    );
  }

  Widget _quarterlyBarChart() {
    return MyBarChart(
      title: 'Spending by quarter',
      bars: dataset.spendingTxns.txnsByQuarter.mapL(
        (Dataset qtr) => Bar(
          title: qtr.transactions.first.date.qtrString,
          value: qtr.totalAmount,
        ),
      ),
    );
  }

  Widget _totalsCard() {
    final totalSpending = dataset.spendingTxns.totalAmount;
    final totalIncome = -dataset.incomeTxns.totalAmount;
    return Card(
      margin: const EdgeInsets.all(50),
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Text(
              'Total income ever: ${totalIncome.asCompactDollars()}',
              style: TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'Total spending ever: ${totalSpending.asCompactDollars()}',
              style: TextStyle(fontSize: 44),
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineChart() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: MyLineChart(
        title: 'Earning vs Spending',
        lines: [
          Line(
            title: 'Earning',
            color: Colors.green[800]!,
            spots: dataset.incomeTxns.transactions.mapL(
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
            spots: dataset.spendingTxns.transactions.mapL(
              (txn) => Spot(
                x: txn.date.toDouble,
                y: txn.amount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
