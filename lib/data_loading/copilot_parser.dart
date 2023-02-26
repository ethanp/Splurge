import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/csv.dart';

import 'loader.dart';

class CopilotExportReader {
  static Future<Dataset?> get loadData async => loader(
        title: 'Copilot',
        filename: 'transactions.csv',
        numHeaderLines: 1,
        parseToTransaction: (text) => CopilotExportRow(text).toTransaction(),
        // I don't like these at all.
        filter: (_) => _.category != 'internal transfer',
      );
}

class CopilotExportRow {
  CopilotExportRow(String rawRow) {
    _rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> _rowValues;

  DateTime get date => DateTime.parse(_rowValues[0]);

  String get title => _rowValues[1];

  double get amount {
    final rawValue = _rowValues[2];
    return rawValue.isEmpty ? 0 : double.parse(rawValue);
  }

  String get category {
    switch (txnType) {
      case 'regular':
        return _rowValues[4];
      case 'income':
        if (title.toLowerCase().contains('payroll')) {
          if (amount.abs() < 5500) {
            return IncomeCategory.Payroll.name;
          } else {
            return IncomeCategory.Bonus.name;
          }
        } else if (title.toLowerCase().contains('brokerage')) {
          return IncomeCategory.GSUs.name;
        } else {
          return IncomeCategory.Random.name;
        }
      case 'internal transfer':
        return txnType;
      default:
        throw Exception('Unknown txnType $txnType in $_rowValues');
    }
  }

  String get txnType => _rowValues[7];

  Transaction toTransaction() => Transaction(
        date: date,
        title: title,
        amount: amount,
        category: category,
        txnType: txnType,
      );
}
