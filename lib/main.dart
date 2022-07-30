import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/charts.dart';
import 'package:splurge/copilot_parser.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions.dart';
import 'package:splurge/util/widgets.dart';

void main() => runApp(AppWidget());

class AppWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Personal finances analyzer')),
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
    final totalSpending = dataset.spendingTxns.totalAmount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Total spending ever: ${totalSpending.asCompactDollars()}',
              style: const TextStyle(fontSize: 24),
            ),
            const Expanded(
              child: MyLineChart(
                title: 'Spending vs Earning',
                lines: [
                  Line(
                    title: 'Spending',
                    spots: [
                      FlSpot(0, 2),
                      FlSpot(1, 2),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyBarChart(
              title: 'Bars by month',
              bars: dataset.spendingTxns.txnsByMonth.mapL(
                (Dataset month) => Bar(
                  title: month.transactions.first.date.monthString,
                  value: month.totalAmount,
                ),
              ),
            ),
            MyBarChart(
              title: 'Bars by quarter',
              bars: dataset.spendingTxns.txnsByQuarter.mapL(
                (Dataset qtr) => Bar(
                  title: qtr.transactions.first.date.qtrString,
                  value: qtr.totalAmount,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
