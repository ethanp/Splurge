import 'package:flutter/material.dart';
import 'package:splurge/charts/bar/my_bar_chart.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class BarCharts extends StatelessWidget {
  const BarCharts({required this.dataset});

  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _monthlyBarChart()),
          Expanded(child: _quarterlyBarChart()),
        ],
      ),
    );
  }

  Widget _monthlyBarChart() {
    final Map<String, Dataset> earning =
        dataset.incomeTxns.txnsByMonth.asMap().map((_, v) => v);

    return MyBarChart(
      title: 'Earning vs Spending by month',
      xTitle: (xVal) => xVal.toDate.monthString,
      barGroups: dataset.spendingTxns.txnsByMonth.mapL(
        (MapEntry<String, Dataset> month) => BarGroup(
          xValue: month.value.transactions.first.date.toDouble.toInt(),
          bars: [
            Bar(
              title: 'Earning',
              value: -earning[month.key]!.totalAmount,
              color: Colors.green[800]!,
            ),
            Bar(
              title: 'Spending',
              value: month.value.totalAmount,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _quarterlyBarChart() {
    final Map<String, Dataset> earning =
        dataset.incomeTxns.txnsByQuarter.asMap().map((_, v) => v);

    return MyBarChart(
      title: 'Earning vs Spending by quarter',
      xTitle: (xVal) => xVal.toDate.qtrString,
      barGroups: dataset.spendingTxns.txnsByQuarter.mapL(
        (MapEntry<String, Dataset> spendingEntry) => BarGroup(
          xValue: spendingEntry.value.transactions.first.date.toDouble.toInt(),
          bars: [
            Bar(
              title: 'Earning',
              value: -earning[spendingEntry.key]!.totalAmount,
              color: Colors.green[800]!,
            ),
            Bar(
              title: 'Spending',
              value: spendingEntry.value.totalAmount,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
