import 'package:flutter/material.dart';
import 'package:splurge/charts/my_bar_chart.dart';
import 'package:splurge/charts/my_line_chart.dart';
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
      // TODO(feature): Add the earnings here too, like for quarters below.
      title: 'Earning vs Spending by month',
      barGroups: dataset.spendingTxns.txnsByMonth.mapL(
        (Dataset month) => BarGroup(
          title: month.transactions.first.date.monthString,
          bars: [
            Bar(
              title: 'Spending',
              value: month.totalAmount,
              color: Colors.red,
            )
          ],
        ),
      ),
    );
  }

  Widget _quarterlyBarChart() {
    final earning =
        dataset.incomeTxns.txnsByQuarter.asMap().map((_, value) => value);

    return MyBarChart(
      title: 'Earning vs Spending by quarter',
      barGroups: dataset.spendingTxns.txnsByQuarter.mapL(
        (spending) => BarGroup(
          title: spending.key,
          bars: [
            Bar(
              title: 'Earning',
              value: -earning[spending.key]!.totalAmount,
              color: Colors.green[800]!,
            ),
            Bar(
              title: 'Spending',
              value: spending.value.totalAmount,
              color: Colors.red,
            ),
          ],
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
            rawSpots: dataset.incomeTxns.transactions.mapL(
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
            rawSpots: dataset.spendingTxns.transactions.mapL(
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
