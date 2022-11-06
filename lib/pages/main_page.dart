import 'package:flutter/material.dart';
import 'package:splurge/widgets/bar_charts.dart';
import 'package:splurge/widgets/filter_card.dart';
import 'package:splurge/widgets/income_v_spending_line_chart.dart';
import 'package:splurge/widgets/totals_card.dart';
import 'package:splurge/widgets/transactions_review.dart';

import 'annual_category_summary_page.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        flex: 3,
        child: Column(children: [
          Row(children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TableComparisonButton(),
                  TotalsCard(),
                ],
              ),
            ),
            FilterCard(),
          ]),
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

class _TableComparisonButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => AnnualCategorySummaryPage(),
          ),
        ),
        child: Text('Table: category comparison by year'),
      ),
    );
  }
}
