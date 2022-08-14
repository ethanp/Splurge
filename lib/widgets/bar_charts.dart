import 'package:flutter/material.dart';
import 'package:splurge/charts/my_bar_chart.dart';
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
}
