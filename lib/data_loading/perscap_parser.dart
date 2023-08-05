import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'loader.dart';

/// The only data extracted from these exports is contributions to
/// tax-advantaged accounts; since those don't make it to Copilot.
///
/// The filtering happens in [PerscapExportRow.category].
///
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

  /// Meant to include only
  ///
  /// 1. 401(k) contributions (including ones mis-categorized by Perscap)
  /// 2. HSA contributions.
  ///
  /// Everything else will get a blank category and will therefore be ignored.
  String get category {
    final bool isLabeledAsRetirement =
        _rawCategory.contains('Retirement Contribution');

    // Perscap sometimes mis-categorizes Vanguard deposits as "Other Income"
    final bool isVanguardContribution =
        title.contains('Target Retire 2055 Tr-plan Contribution');

    final bool is529Contribution = title.contains('Schwab Lq Ach Contrib');

    final bool isRetirementContribution =
        !is529Contribution && (isLabeledAsRetirement || isVanguardContribution);

    // Discard anything that's not a retirement contribution.
    return isRetirementContribution ? IncomeCategory.TaxAdvContrib.name : '';
  }

  String get _rawCategory => _rowValues[3];

  String get txnType => category.isNotEmpty ? 'income' : '';

  Transaction toTransaction() => Transaction(
        date: date,
        title: title,
        amount: amount,
        category: category,
        txnType: txnType,
      );
}
