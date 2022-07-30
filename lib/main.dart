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
    final totalSpending = dataset.spendingTxns.sumBy((e) => e.amount);
    // TODO(UI): Format the $amt nicely like in the financial simulator.
    return Text('Total spending: $totalSpending');
  }
}
