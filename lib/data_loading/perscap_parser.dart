import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'loader.dart';

class PerscapExportReader {
  static Future<Dataset?> get loadData async => loader(
        title: 'Perscap',
        fileSubstring: ' thru ',
        numHeaderLines: 2,
        parseToTransaction: (text) => PerscapExportRow(text).toTransaction(),
        filter: (txn) =>
            txn.category == IncomeCategory.TaxAdvContrib.name &&
            txn.date.isAtLeast(DateTime(/*year*/ 2021, /*month*/ 3)),
      );
}

class PerscapExportRow {
  PerscapExportRow(String rawRow) {
    _rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> _rowValues;

  DateTime get date => DateTime.parse(_rowValues[0]);

  // Example actual rowValue[5]s: ["17.7", "-15.83", "8", "-200", "4636.53"].
  double get amount => -double.parse(_rowValues[5]);

  String get title =>
      _rowValues[2] == 'Investment: Viiix' ? 'HSA contribution' : _rowValues[2];

  String get accountName => _rowValues[4];

  /// This includes 401(k) contributions (including ones mis-categorized by
  /// Perscap), as well as HSA contributions.
  String get category => _rowValues[3].contains('Retirement Contribution') ||
          // Perscap sometimes mis-categorizes these as "Other Income"
          title.contains('Target Retire 2055 Tr-plan Contribution')
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
