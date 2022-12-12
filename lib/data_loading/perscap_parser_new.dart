import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'loader.dart';

class NewPerscapExportReader {
  static Future<Dataset?> get loadData async => loader(
        title: 'Perscap',
        fileSubstring: ' thru ',
        numHeaderLines: 2,
        parseToTransaction: (text) => NewPerscapExportRow(text).toTransaction(),
        filter: (txn) =>
            txn.category == IncomeCategory.TaxAdvContrib.name &&
            txn.date.isAtLeast(DateTime(/*year*/ 2021, /*month*/ 3)),
      );
}

class NewPerscapExportRow {
  NewPerscapExportRow(String rawRow) {
    rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> rowValues;

  DateTime get date => DateTime.parse(rowValues[0]);

  // Example actual values: ["17.7", "-15.83", "8", "-200", "4636.53"].
  double get amount => -double.parse(rowValues[5]);

  String get title => rowValues[2];

  String get accountName => rowValues[4];

  /// Right now 401(k) is the only useful data getting extracted from this dump.
  /// NB: HSA contribution data is not available here AFAICT.
  String get category => accountName.contains('401(k)')
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
