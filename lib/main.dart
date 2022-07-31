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
    final totalSpending = dataset.spendingTxns.totalAmount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Total spending ever: ${totalSpending.asCompactDollars()}',
                style: TextStyle(fontSize: 44),
              ),
              Expanded(
                child: MyLineChart(
                  title: 'Spending vs Earning',
                  lines: [
                    Line(
                      title: 'Spending',
                      color: Colors.red,
                      spots: [
                        FlSpot(0, 2),
                        FlSpot(1, 2),
                      ],
                    ),
                    Line(
                      title: 'Earning',
                      color: Colors.green[800]!,
                      spots: [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: MyBarChart(
                  title: 'Spending by month',
                  bars: dataset.spendingTxns.txnsByMonth.mapL(
                    (Dataset month) => Bar(
                      title: month.transactions.first.date.monthString,
                      value: month.totalAmount,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MyBarChart(
                  title: 'Spending by quarter',
                  bars: dataset.spendingTxns.txnsByQuarter.mapL(
                    (Dataset qtr) => Bar(
                      title: qtr.transactions.first.date.qtrString,
                      value: qtr.totalAmount,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
