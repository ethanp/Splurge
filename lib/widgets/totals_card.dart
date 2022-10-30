import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';

import '../util/extensions/stdlib_extensions.dart';

class TotalsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTimeRange selectedDateRange =
        ref.watch(SelectedDateRange.provider);

    final Dataset dataset = ref.watch(DatasetNotifier.filteredProvider);
    final double totalIncome = -dataset.incomeTxns.totalAmount;
    final double totalSpending = dataset.spendingTxns.totalAmount;

    const Color deepBluePurple = Color.fromRGBO(40, 10, 30, 1);

    final incomeLine = _TextLine(
      prefix: '     Income:',
      color: Colors.green[400]!,
      amt: totalIncome,
      dateRange: selectedDateRange,
    );
    final spendingLine = _TextLine(
      prefix: '– Spending:',
      color: Colors.red,
      amt: totalSpending,
      dateRange: selectedDateRange,
    );
    final savingsLine = _TextLine(
      prefix: '     Savings:',
      color: Colors.blue[700]!,
      amt: totalIncome - totalSpending,
      dateRange: selectedDateRange,
    );

    return SizedBox(
      width: 410,
      child: Card(
        margin: const EdgeInsets.all(12),
        shape: Shape.roundedRect(circular: 20),
        color: deepBluePurple,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 18,
            bottom: 14,
            top: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColumnDescriptors(),
              incomeLine,
              spendingLine,
              _DividerLine(),
              savingsLine,
              _DateBound(selectedDateRange),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBound extends StatelessWidget {
  const _DateBound(this.selectedDateRange);

  final DateTimeRange selectedDateRange;

  @override
  Widget build(BuildContext context) {
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
          style: _defaultFont.copyWith(
            fontSize: 12,
            color: Colors.blueGrey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        bottom: 2,
        left: 18,
        right: 4,
      ),
      height: 3,
      color: Colors.grey,
    );
  }
}

class _ColumnDescriptors extends StatelessWidget {
  const _ColumnDescriptors();

  @override
  Widget build(BuildContext context) {
    const String space = '             ';
    return Row(
      children: [
        SizedBox(width: 190),
        Text(
          'raw $space annualized',
          style: _defaultFont.copyWith(
            color: Colors.grey[700],
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _TextLine extends StatelessWidget {
  const _TextLine({
    required this.prefix,
    required this.color,
    required this.amt,
    required this.dateRange,
  });

  final String prefix;
  final Color color;
  final double amt;
  final DateTimeRange dateRange;

  @override
  Widget build(BuildContext context) {
    final double numYears = dateRange.duration.inDays / 365.0;
    final double annualizedAmt = amt / numYears;

    return Row(
      children: [
        _cell(
          text: prefix,
          width: 140,
        ),
        _cell(
          text: amt.asCompactDollars(),
          width: 98,
        ),
        _cell(
          text: annualizedAmt.asCompactDollars(),
          width: 98,
        ),
      ],
    );
  }

  Widget _cell({
    required String text,
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: _defaultFont.copyWith(
          color: color,
          fontSize: 21,
        ),
      ),
    );
  }
}

TextStyle get _defaultFont => GoogleFonts.merriweather(fontSize: 30);
