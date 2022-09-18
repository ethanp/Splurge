import 'dart:io';

import 'package:splurge/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/errors.dart';

class PerscapExportReader {
  // TODO(feature): Load this data into the global dataset provider. We may end
  //  up wanting it to be its *own* line on the main chart. But to start, let's
  //  just count it as income.
  static Future<Dataset> get loadData async {
    try {
      final downloads = Directory('/Users/Ethan/Downloads').list();
      final perscapDumpCsv = downloads.firstWhere(
        (f) => f.path.contains('Transactions_For_All_Accounts'),
      ) as File;
      print('Parsing Perscap dump');
      final dumpContents = await perscapDumpCsv.readAsString();
      final txns = dumpContents
          .split('\n')
          .skip(2) // Skip title & header rows.
          .map((text) => PerscapExportRow(text).toTransaction())
          .where((txn) => txn.category == IncomeCategory.TaxAdvContrib.name);
      return Dataset(txns);
    } catch (e) {
      throw FileReadError('Perscap parse issue! $e');
    }
  }
}

class PerscapExportRow {
  PerscapExportRow(String rawRow) {
    rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> rowValues;

  DateTime get date => DateTime.parse(rowValues[0]);

  String get title => rowValues[1];

  double get amount {
    // Original format looks like "$30.00", or "-$2,024.43".
    final rawValue = rowValues[5];
    final dbl = rawValue.substring(rawValue[0] == '-' ? 2 : 1);
    return double.parse(dbl);
  }

  /// Right now 401(k) is the only useful data getting extracted from this dump.
  /// NB: HSA contribution data is not available here AFAICT.
  String get category => rowValues[4].contains('401(k)')
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
