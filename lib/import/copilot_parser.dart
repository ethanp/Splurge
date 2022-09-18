// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:splurge/data_model.dart';
import 'package:splurge/util/csv.dart';
import 'package:splurge/util/errors.dart';

class CopilotExportReader {
  static Future<Dataset> get loadData async {
    try {
      final file = File('/Users/Ethan/Downloads/transactions.csv');
      print('Parsing Copilot dump');
      final dumpContents = (await file.readAsString());
      final txns = dumpContents
          .split('\n')
          .skip(1) // Skip header.
          .map(CopilotExportRow.new)
          .map((row) => row.toTransaction());
      return Dataset(txns);
    } catch (e) {
      throw FileReadError('Copilot parse issue! $e');
    }
  }
}

class CopilotExportRow {
  CopilotExportRow(String rawRow) {
    rowValues = ValueGeneratorCommaSeparated(rawRow).toList(growable: false);
  }

  late final List<String> rowValues;

  DateTime get date => DateTime.parse(rowValues[0]);

  String get title => rowValues[1];

  double get amount {
    final rawValue = rowValues[2];
    return rawValue.isEmpty ? 0 : double.parse(rawValue);
  }

  String get category {
    switch (txnType) {
      case 'regular':
        return rowValues[4];
      case 'income':
        if (title.toLowerCase().contains('payroll')) {
          if (amount.abs() < 5000) {
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
        throw Exception('Unknown txnType $txnType in $rowValues');
    }
  }

  String get txnType => rowValues[7];

  Transaction toTransaction() => Transaction(
        date: date,
        title: title,
        amount: amount,
        category: category,
        txnType: txnType,
      );
}

enum IncomeCategory {
  Payroll,
  Bonus,
  GSUs,
  Random;
}

extension IncomeCat on String {
  bool get isIncome => IncomeCategory.values.any((i) => i.name == this);
}
