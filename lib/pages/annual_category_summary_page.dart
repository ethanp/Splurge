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
    final firstYear = dataset.txns.first.date.year;
    final lastYear = dataset.txns.last.date.year;
    final yearsWithData = firstYear.toInclusive(lastYear);
    final yearColumns = yearsWithData.mapL(
      (year) => DataColumn(
        label: Text(year.toString()),
        numeric: true,
      ),
    );
    final columns = [DataColumn(label: Text('Category'))] + yearColumns;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[700],
        title: Text('Spending per category per year (annualized)'),
      ),
      // The [Row] exists so the table doesn't stretch to the full screen width.
      body: Row(children: [
        Card(
          margin: const EdgeInsets.all(8),
          color: Colors.grey[900],
          child: DataTable(
            border: TableBorder.all(),
            columns: columns,
            rows: _categoryRows(dataset, yearsWithData),
          ),
        ),
      ]),
    );
  }

  List<DataRow> _categoryRows(Dataset dataset, Iterable<int> yearsWithData) {
    final categoryStyle = GoogleFonts.aBeeZee(fontSize: 16);
    final years = yearsWithData
        .map((year) => DateRange.just(year: year, atMostNow: true));
    return dataset.txnsPerCategory.entries.mapL((entry) {
      final txns = entry.value.txns;
      final DataCell categoryName =
          DataCell(Text(entry.key, style: categoryStyle));
      final Iterable<DataCell> yearlyCategoryValues = years
          .map((year) => Dataset(txns.where((t) => t.isWithinDateRange(year))))
          .map(_annualizeSpending)
          .map(_formatText)
          .map((e) => DataCell(e));
      return DataRow(cells: [categoryName, ...yearlyCategoryValues]);
    });
  }

  Widget _formatText(num amt) {
    return Text(
      amt.asCompactDollars(),
      style: GoogleFonts.abel(
        fontSize: 16,
        color: () {
          if (amt == 0)
            return Colors.grey[700];
          else if (amt.isNegative)
            return Colors.green[400];
          else
            return Colors.red[300];
        }(),
      ),
    );
  }

  double _annualizeSpending(Dataset txnsForCategoryForYear) {
    // Avoid calculations on nothingness for simplicity.
    if (txnsForCategoryForYear.isEmpty) return 0;
    final firstDate = txnsForCategoryForYear.txns.first.date;
    final lastDate = txnsForCategoryForYear.txns.last.date;
    final range = DateTimeRange(start: firstDate, end: lastDate);
    var annualizationFactor = range.duration.inDays / 365.0;
    // Avoid divide by zero for simplicity.
    if (annualizationFactor == 0) annualizationFactor = 1;
    return txnsForCategoryForYear.totalAmount / annualizationFactor;
  }
}
