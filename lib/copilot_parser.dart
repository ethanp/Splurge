// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:splurge/data_model.dart';
import 'package:splurge/util/errors.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

class CopilotExportReader {
  static Future<Dataset> get loadData async {
    try {
      final file = File('/Users/Ethan/Downloads/transactions.csv');
      return _parse(await file.readAsString());
    } catch (e) {
      throw FileReadError('Uh oh! $e');
    }
  }

  static Dataset _parse(String filetext) {
    print('Parsing file');
    return Dataset(filetext
        .split('\n')
        .skip(1) // Skip header.
        .map(CopilotExportRow.new)
        .mapL((row) => row.toTransaction())
        .reversed // Sort into chronological order.
        .toList());
  }
}

/// Pure-boilerplate :(
class CopilotExportValueGenerator extends Iterable<String> {
  CopilotExportValueGenerator(this.rawRow);

  final String rawRow;

  @override
  Iterator<String> get iterator => CopilotExportValueSplitter(rawRow);
}

/// Isn't data fun.
class CopilotExportValueSplitter extends Iterator<String> {
  CopilotExportValueSplitter(this.rawRow);

  final String rawRow;

  int cursorPosition = 0;

  String get curChar => rawRow[cursorPosition];

  @override
  bool moveNext() {
    if (done) return false;
    current = curChar == '"' ? _extractFromQuotes() : _extractNoQuotes();
    return !done;
  }

  bool get done => cursorPosition >= rawRow.length;

  @override
  String current = '';

  String _extractFromQuotes() {
    int openQuoteLoc = cursorPosition;
    cursorPosition++;
    while (curChar != '"' && !done) {
      cursorPosition++;
    }
    cursorPosition++; // Close quote

    // Weird bug in the raw csv where there can be an extra pair of quotes!
    var offset = 0;
    if (!done && curChar == '"') {
      cursorPosition += 2; // skip the quotes
      offset = 2;
    }

    cursorPosition++; // Comma
    return rawRow.substring(openQuoteLoc + 1, cursorPosition - 2 - offset);
  }

  String _extractNoQuotes() {
    int start = cursorPosition;
    while (curChar != ',' && !done) {
      cursorPosition++;
    }
    cursorPosition++;
    return rawRow.substring(start, cursorPosition - 1);
  }
}

class CopilotExportRow {
  CopilotExportRow(String rawRow) {
    rowValues = CopilotExportValueGenerator(rawRow).toList(growable: false);
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
