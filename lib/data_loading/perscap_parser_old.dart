import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'loader.dart';

/// This is the "old" one because it's from before Personal Capital reformatted
/// their export format. I'm keeping this code here for now in case their format
/// happens to revert back (which already seems unlikely since it has now been
/// two months on the new format).
///
class OldPerscapExportReader {
  static Future<Dataset?> get loadData async => loader(
        title: 'Perscap',
        fileSubstring: 'Transactions_For_All_Accounts',
        numHeaderLines: 2,
        parseToTransaction: (text) => OldPerscapExportRow(text).toTransaction(),
        filter: (txn) =>
            txn.category == IncomeCategory.TaxAdvContrib.name &&
            txn.date.isAtLeast(DateTime(/*year*/ 2021, /*month*/ 3)),
      );
}

class OldPerscapExportRow {
  OldPerscapExportRow(String rawRow) {
    _rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> _rowValues;

  DateTime get date => DateTime.parse(_rowValues[0]);

  String get title => _rowValues[1];

  // Original format looks like "$30.00", or "-$2,024.43".
  //
  // Also, negativity is reversed from Copilot, so we invert.
  double get amount =>
      -double.parse(_rowValues[5].replaceAll('\$', '').replaceAll(',', ''));

  /// Right now 401(k) is the only useful data getting extracted from this dump.
  /// NB: HSA contribution data is not available here AFAICT.
  String get category => _rowValues[4].contains('401(k)')
      ? IncomeCategory.TaxAdvContrib.name
      // These get filtered out, so the value doesn't matter.
      : '';

  String get txnType => category.isNotEmpty ? 'income' : '';

  Transaction toTransaction() => Transaction(
        date: date,
        title: title,
        amount: amount,
        category: category,
        txnType: txnType,
      );
}
