import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class AnnualCategorySummaryPage extends ConsumerWidget {
  const AnnualCategorySummaryPage();

  static final _rng = Random(0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.read(DatasetNotifier.unfilteredProvider);

    final categoryStyle = GoogleFonts.aBeeZee(
      fontSize: 16,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Table of annualized spending per category per year'),
      ),
      body: Table(
        border: TableBorder.all(),
        children: [
          TableRow(
            children: [
              'Category',
              // TODO(hack): Dynamically generate all years from 2021 on.
              '2021',
              '2022',
              'Difference',
            ].mapL(
              (text) => Container(
                padding: const EdgeInsets.all(4),
                color: Colors.grey[700],
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aBeeZee(
                    fontWeight: FontWeight.w800,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),
          ...dataset.categories.mapL(
            (cat) {
              // TODO get real values.
              final twentyOne = 200 + _rng.nextDouble() * 200;
              final twentyTwo = 200 + _rng.nextDouble() * 200;
              final savings = twentyOne - twentyTwo;

              return TableRow(
                children: (([
                  Text(cat, style: categoryStyle),
                  Text(twentyOne.asExactDollars(), style: categoryStyle),
                  Text(twentyTwo.asExactDollars(), style: categoryStyle),
                  Text(
                    savings.asExactDollars(),
                    style: categoryStyle.copyWith(
                      color: savings.isNegative ? Colors.red : Colors.green,
                    ),
                  ),
                ])).mapL(
                  (e) => Padding(padding: const EdgeInsets.all(12), child: e),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
