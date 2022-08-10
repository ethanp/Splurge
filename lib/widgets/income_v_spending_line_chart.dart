import 'package:flutter/material.dart';
import 'package:splurge/charts/my_line_chart.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/fl_chart_extensions.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class IncomeVsSpendingLineChart extends StatelessWidget {
  const IncomeVsSpendingLineChart({
    required this.incomeTxns,
    required this.spendingTxns,
  });

  final Dataset incomeTxns;
  final Dataset spendingTxns;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: MyLineChart(
        title: 'Earning vs Spending',
        lines: [
          Line(
            title: 'Earning',
            color: Colors.green[800]!,
            rawSpots: incomeTxns.transactions.mapL(
              (txn) => Spot(
                x: txn.date.toDouble,
                // Make earning easier to compare with spending by inverting.
                y: -txn.amount,
              ),
            ),
          ),
          Line(
            title: 'Spending',
            color: Colors.red,
            rawSpots: spendingTxns.transactions.mapL(
              (txn) => Spot(
                x: txn.date.toDouble,
                y: txn.amount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
