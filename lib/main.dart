import 'package:flutter/material.dart';
import 'package:splurge/bar_chart_sample_5.dart';
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
        Center(
          child: Text(
            'Total spending ever: ${totalSpending.asCompactDollars()}',
            style: const TextStyle(fontSize: 24),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            MyBarChart(
              title: 'By month',
              bars: dataset.spendingTxns.txnsByMonth.mapL(
                (Dataset month) => Bar(
                  title: month.transactions.first.date.monthString,
                  value: month.totalAmount,
                ),
              ),
            ),
            MyBarChart(
              title: 'By quarter',
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

class Bar {
  const Bar({required this.title, required this.value});

  final String title;
  final double value;
}

class MyBarChart extends StatelessWidget {
  const MyBarChart({required this.title, required this.bars});

  final String title;
  final List<Bar> bars;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          Text(bars
              .map((bar) => '${bar.title} ${bar.value.asCompactDollars()}')
              .join('\n')),
          const BarChartSample5(),
        ],
      ),
    );
  }
}
