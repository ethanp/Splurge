import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:splurge/global/providers.dart';

import '../util/extensions/stdlib_extensions.dart';

class TotalsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateRange = ref.watch(SelectedDateRange.provider);

    final dataset = ref.watch(DatasetNotifier.filteredProvider);
    final totalIncome = -dataset.incomeTxns.totalAmount;
    final totalSpending = dataset.spendingTxns.totalAmount;

    return SizedBox(
      width: 400,
      child: Card(
        margin: const EdgeInsets.all(12),
        shape: Shape.roundedRect(circular: 20),
        color: Colors.black.withGreen(10).withRed(40).withBlue(30),
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textLine(
                prefix: '     Income:       ',
                color: Colors.green[400]!,
                amt: totalIncome,
                dateRange: selectedDateRange,
              ),
              _textLine(
                prefix: '– Spending:   ',
                color: Colors.red,
                amt: totalSpending,
                dateRange: selectedDateRange,
              ),
              _dividerLine(),
              _textLine(
                prefix: '     Savings:       ',
                color: Colors.blue[700]!,
                amt: totalIncome - totalSpending,
                dateRange: selectedDateRange,
              ),
              _dateBound(selectedDateRange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textLine({
    required String prefix,
    required Color color,
    required double amt,
    required DateTimeRange dateRange,
  }) {
    final double numYears = dateRange.duration.inDays / 365.0;
    final double annualizedAmt = amt / numYears;
    // Give room for the negative sign.
    if (amt < 0) prefix = prefix.substring(0, prefix.length - 3);
    return AutoSizeText(
      '$prefix${amt.asCompactDollars()}   ${annualizedAmt.asCompactDollars()}',
      style: defaultFont.copyWith(color: color),
      maxLines: 1,
    );
  }

  Widget _dividerLine() {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 2,
        left: 12,
        right: 28,
      ),
      height: 3,
      color: Colors.grey,
    );
  }

  Widget _dateBound(DateTimeRange selectedDateRange) {
    String format(DateTime d) => DateFormat('MMMM d, y').format(d);
    final start = format(selectedDateRange.start);
    final end = format(selectedDateRange.end);
    final text = 'From $start -through- $end';

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: AutoSizeText(
          text,
          textAlign: TextAlign.right,
          style: defaultFont.copyWith(
            fontSize: 12,
            color: Colors.blueGrey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  static TextStyle get defaultFont => GoogleFonts.merriweather(fontSize: 30);
}
