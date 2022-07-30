import 'dart:io';

import 'package:splurge/data_model.dart';
import 'package:splurge/util/errors.dart';
import 'package:splurge/util/extensions.dart';

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
        .mapL((row) => row.toTransaction()));
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
  bool moveNext() => cursorPosition < rawRow.length;

  @override
  String get current =>
      curChar == '"' ? _extractFromQuotes() : _extractNoQuotes();

  String _extractFromQuotes() {
    int start = cursorPosition;
    cursorPosition++;
    while (curChar != '"' && moveNext()) {
      cursorPosition++;
    }
    cursorPosition++; // Close quote

    // Weird bug in the raw csv where there can be an extra pair of quotes!
    var offset = 0;
    if (moveNext() && curChar == '"') {
      cursorPosition += 2; // skip the quotes
      offset = 2;
    }

    cursorPosition++; // Comma
    return rawRow.substring(start + 1, cursorPosition - 2 - offset);
  }

  String _extractNoQuotes() {
    int start = cursorPosition;
    while (curChar != ',' && moveNext()) {
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

  static String removeSurroundingQuotes(String rawValue) =>
      rawValue.length >= 2 && rawValue.startsWith('"') && rawValue.endsWith('"')
          ? rawValue.substring(1, rawValue.length - 1)
          : rawValue;

  late final List<String> rowValues;

  DateTime get date => DateTime.parse(rowValues[0]);

  String get title => rowValues[1];

  double get amount {
    final rawValue = rowValues[2];
    return rawValue.isEmpty ? 0 : double.parse(rawValue);
  }

  String get category => rowValues[4];

  String get txnType => rowValues[7];

  Transaction toTransaction() => Transaction(
        date: date,
        title: title,
        amount: amount,
        category: category,
        txnType: txnType,
      );
}
