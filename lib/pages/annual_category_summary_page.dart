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
      // The [Row] exists so the table doesn't stretch to the full screen width.
      body: Row(children: [
        DataTable(
          border: TableBorder.all(),
          columns: const [
            DataColumn(label: Text('Category')),
            // TODO(hack): Dynamically generate all years from 2021 on.
            // Note: `numeric` sets it to right-aligned.
            DataColumn(label: Text('2021'), numeric: true),
            DataColumn(label: Text('2022'), numeric: true),
            DataColumn(label: Text('difference'), numeric: true),
          ],
          rows: _categoryRows(dataset),
        ),
      ]),
    );
  }

  List<DataRow> _categoryRows(Dataset dataset) {
    final categoryStyle = GoogleFonts.aBeeZee(
      fontSize: 16,
    );

    final year21 = DateRange.just(year: 2021);
    final year22 = DateRange.just(year: 2022);

    return dataset.txnsPerCategory.entries.mapL((entry) {
      final twentyOne = _annualized(entry.value, year21);
      final twentyTwo = _annualized(entry.value, year22);
      final savings = twentyOne - twentyTwo;

      return DataRow(
        cells: [
          Text(entry.key, style: categoryStyle),
          Text(twentyOne.asExactDollars(), style: categoryStyle),
          Text(twentyTwo.asExactDollars(), style: categoryStyle),
          Text(
            savings.asExactDollars(),
            style: categoryStyle.copyWith(
              color: savings.isNegative ? Colors.red : Colors.green,
            ),
          ),
        ].mapL((cellChildWidget) => DataCell(cellChildWidget)),
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
