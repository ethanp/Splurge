import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';
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
            Expanded(child: FilterCard()),
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
    final iconAndText = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(Icons.table_view, size: 36),
        Expanded(
          child: AutoSizeText(
            'Table: category comparison by year',
            style: GoogleFonts.robotoSlab(fontSize: 29),
            maxLines: 1,
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        width: 400,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: Shape.roundedRect(circular: 10),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => AnnualCategorySummaryPage(),
            ),
          ),
          child: iconAndText,
        ),
      ),
    );
  }
}
