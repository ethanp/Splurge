import 'package:flutter/material.dart';
import 'package:splurge/widgets/bar_charts.dart';
import 'package:splurge/widgets/filter_card.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/totals_card.dart';
import 'package:splurge/widgets/transactions_review.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 3,
        child: Column(children: [
          Row(children: [TotalsCard(), FilterCard()]),
          Expanded(child: IncomeVsSpendingLineChart()),
        ]),
      ),
      Expanded(
        flex: 2,
        child: Column(children: [
          Expanded(child: BarCharts()),
          Expanded(child: LargestTransactions()),
        ]),
      ),
    ]);
  }
}
