import 'package:flutter/material.dart';
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

  // TODO(refactor): This should be "provided", not passed-in.
  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    final totalSpending = dataset.spendingTxns.totalAmount;

    String asMonthTable(Dataset month) =>
        '${month.transactions.first.date.monthString}'
        '   ${month.totalAmount.asCompactDollars()}';
    String asQtrTable(Dataset month) =>
        '${month.transactions.first.date.qtrString}'
        '   ${month.totalAmount.asCompactDollars()}';

    // TODO(UI): These should be bar charts, with clickable bars or something.
    final spendingByMonth =
        dataset.spendingTxns.txnsByMonth.map(asMonthTable).join('\n');
    final spendingByQuarter =
        dataset.spendingTxns.txnsByQuarter.map(asQtrTable).join('\n');

    return Column(
      children: [
        Text('Total spending: ${totalSpending.asCompactDollars()}'),
        Text('By month:\n$spendingByMonth'),
        Text('By quarter:\n$spendingByQuarter'),
      ],
    );
  }
}
