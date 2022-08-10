import 'package:flutter/material.dart';
import 'package:splurge/charts/my_bar_chart.dart';
import 'package:splurge/copilot_parser.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/widgets.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/largest_transactions.dart';
import 'package:splurge/widgets/totals_card.dart';

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
          child: Column(
            children: [
              Expanded(child: _monthlyBarChart()),
              Expanded(child: _quarterlyBarChart()),
              Expanded(child: LargestTransactions(dataset: dataset)),
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
}
