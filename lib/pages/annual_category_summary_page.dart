import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class AnnualCategorySummaryPage extends ConsumerWidget {
  const AnnualCategorySummaryPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(DatasetNotifier.unfilteredProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Table of annualized spending per category per year'),
      ),
      body: Table(
        border: TableBorder.all(),
        children: [_headerRow(), ..._categoryRows(dataset)],
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      children: [
        'Category',
        // TODO(hack): Dynamically generate all years from 2021 on.
        '2021',
        '2022',
        'Difference',
      ].mapL(
        (text) => Container(
          padding: const EdgeInsets.all(12),
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
    );
  }

  List<TableRow> _categoryRows(Dataset dataset) {
    final categoryStyle = GoogleFonts.aBeeZee(
      fontSize: 16,
    );

    final year21 = DateRange.just(year: 2021);
    final year22 = DateRange.just(year: 2022);

    return dataset.txnsPerCategory.entries.mapL((entry) {
      final twentyOne = _annualized(entry.value, year21);
      final twentyTwo = _annualized(entry.value, year22);
      final savings = twentyOne - twentyTwo;

      return TableRow(
        children: (([
          Text(entry.key, style: categoryStyle),
          Text(twentyOne.asExactDollars(), style: categoryStyle),
          Text(twentyTwo.asExactDollars(), style: categoryStyle),
          Text(
            savings.asExactDollars(),
            style: categoryStyle.copyWith(
              color: savings.isNegative ? Colors.red : Colors.green,
            ),
          ),
        ])).mapL(
          (text) => Padding(padding: const EdgeInsets.all(12), child: text),
        ),
      );
    });
  }

  double _annualized(Dataset categoryTxns, DateTimeRange range) {
    final dataset =
        Dataset(categoryTxns.txns.where((txn) => txn.isWithinDateRange(range)));
    final annualizationFactor = range.duration.inDays / 365.0;
    return dataset.totalAmount / annualizationFactor;
  }
}
