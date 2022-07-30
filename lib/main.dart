import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(EmptyApp());

class EmptyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Empty app')),
        body: Center(
          child: Column(
            children: [
              const Text('App booted successfully'),
              FutureBuilder<List<Transaction>>(
                future: CopilotExportReader.loadData,
                builder: (ctx, snapshot) => snapshot.hasData
                    ? Text(snapshot.data!.first.title)
                    : const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CopilotExportReader {
  static Future<List<Transaction>> get loadData async {
    try {
      final file = File('/Users/Ethan/Downloads/transactions.csv');
      return _parse(await file.readAsString());
    } catch (e) {
      throw FileReadError('Uh oh! $e');
    }
  }

  static List<Transaction> _parse(String filetext) {
    print('Parsing file');
    return filetext
        .split('\n')
        .skip(1) // Skip header.
        .map(CopilotExportRow.new)
        .map(Transaction.new)
        .toList();
  }
}

extension SIterator<T> on Iterable<T> {
  List<U> mapL<U>(U Function(T) mapper) => map(mapper).toList(growable: false);
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

  String get txnType => rowValues[5];
}

class Transaction {
  Transaction(CopilotExportRow row)
      : date = row.date,
        title = row.title,
        amount = row.amount,
        category = row.category,
        txnType = row.txnType;

  final DateTime date;
  final String title;
  final double amount;
  final String category;
  final String txnType;
}

class FileReadError extends StateError {
  FileReadError(String message) : super(message);
}
