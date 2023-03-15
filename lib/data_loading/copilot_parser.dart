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

  DateTime get _date => DateTime.parse(_rowValues[0]);

  String get _title => _rowValues[1];

  double get _amount {
    final String amountStr = _rowValues[2];
    return amountStr.isEmpty ? 0 : double.parse(amountStr);
  }

  String get _category {
    switch (_txnType) {
      case 'regular':
        return _rawCategory;
      case 'income':
        return _incomeCategory;
      case 'internal transfer':
        return _txnType;
      default:
        throw Exception('Unknown txnType $_txnType from Copilot: $_rowValues');
    }
  }

  String get _rawCategory => _rowValues[4];

  String get _txnType => _rowValues[7];

  Transaction toTransaction() => Transaction(
        date: _date,
        title: _title,
        amount: _amount,
        category: _category,
        txnType: _txnType,
      );

  String get _incomeCategory {
    if (_title.toLowerCase().contains('payroll')) {
      // This probably won't perfectly differentiate, but it's pretty good.
      if (_amount.abs() < 6000) {
        return IncomeCategory.Payroll.name;
      } else {
        return IncomeCategory.Bonus.name;
      }
    } else if (_title.toLowerCase().contains('brokerage')) {
      return IncomeCategory.GSUs.name;
    } else {
      return IncomeCategory.Random.name;
    }
  }
}
