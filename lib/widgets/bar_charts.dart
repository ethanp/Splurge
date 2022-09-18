import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/charts/bar/my_bar_chart.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class BarCharts extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(DatasetNotifier.filteredProvider);

    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.grey[900],
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 2),
        child: Column(
          children: <Widget>[
            Expanded(child: _monthlyBarChart(dataset)),
            Expanded(child: _quarterlyBarChart(dataset)),
          ].separatedBy(
            const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }

  Widget _monthlyBarChart(Dataset dataset) {
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
          final firstDate = dataset.txns.first.date.toInt;
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

  // TODO(math bug): Steps to reproduce:
  //
  //  1. Select the rent category, with no title filter.
  //  2. Compare the spending by month in Q3 vs Q4 of 2021.
  //  3. Compare the spending by quarter in Q3 vs Q4 of '21.
  //  4. It's easy to see that (2) != (3) which comes out looking like there's
  //     a problem with the quarter calculation.
  //
  //  However, this is a low-priority bug, since I never found this quarterly-
  //   chart to provide any value anyhow.
  Widget _quarterlyBarChart(Dataset dataset) {
    final Map<String, Dataset> earning =
        dataset.incomeTxns.txnsByQuarter.asMap().map((_, v) => v);

    return MyBarChart(
      title: 'Earning vs Spending by quarter',
      xTitle: (xVal) => xVal.toDate.qtrString,
      barGroups: dataset.spendingTxns.txnsByQuarter.mapL(
        (MapEntry<String, Dataset> spendingEntry) => BarGroup(
          xValue: spendingEntry.value.txns.first.date.toInt,
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
