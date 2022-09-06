import 'package:flutter/material.dart';
import 'package:splurge/charts/bar/my_bar_chart.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class BarCharts extends StatelessWidget {
  const BarCharts({required this.dataset});

  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.grey[900],
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 2),
        child: Column(
          children: <Widget>[
            Expanded(child: _monthlyBarChart()),
            Expanded(child: _quarterlyBarChart()),
          ].separatedBy(
            const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }

  Widget _monthlyBarChart() {
    Map<String, Dataset> f(Dataset d) => d.txnsByMonth.asMap().map((_, v) => v);

    final Map<String, Dataset> earningMap = f(dataset.incomeTxns);
    final Map<String, Dataset> spendingMap = f(dataset.spendingTxns);

    final Set<String> mapKeys =
        [earningMap, spendingMap].expand((_) => _.keys).toSet();

    return MyBarChart(
      title: 'Earning vs Spending by month',
      xTitle: (xVal) => xVal.toDate.monthString,
      barGroups: mapKeys.mapL(
        (String month) {
          final dataset = (spendingMap[month] ?? earningMap[month])!;
          final firstDate = dataset.transactions.first.date.toInt;
          return BarGroup(
            xValue: firstDate,
            bars: [
              Bar(
                title: 'Earning',
                value: -(earningMap[month]?.totalAmount ?? 0),
                color: Colors.green[800]!,
              ),
              Bar(
                title: 'Spending',
                value: spendingMap[month]?.totalAmount ?? 0,
                color: Colors.red,
              ),
            ],
          );
        },
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
          xValue: spendingEntry.value.transactions.first.date.toInt,
          bars: [
            Bar(
              title: 'Earning',
              value: -(earning[spendingEntry.key]?.totalAmount ?? 0),
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
