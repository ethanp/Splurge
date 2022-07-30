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
        .map(
          // TODO(major bug): We're splitting but ignoring the quotes. We should
          //  not split inside the quotes. Many titles have commas in them so it
          //  breaks everything.
          (line) => line.split(',').mapL(removeSurroundingQuotes),
        )
        .map(CopilotExportRow.new)
        .map(Transaction.new)
        .toList();
  }

  static String removeSurroundingQuotes(String rawValue) =>
      rawValue.length >= 2 && rawValue.startsWith('"') && rawValue.endsWith('"')
          ? rawValue.substring(1, rawValue.length - 1)
          : rawValue;
}

extension SIterator<T> on Iterable<T> {
  List<U> mapL<U>(U Function(T) mapper) => map(mapper).toList(growable: false);
}

class CopilotExportRow {
  CopilotExportRow(this.rowValues) {
    print('Creating a transaction from $rowValues');
  }

  final List<String> rowValues;

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
        txnType = row.txnType {
    print('Created a transaction');
  }

  final DateTime date;
  final String title;
  final double amount;
  final String category;
  final String txnType;
}

class FileReadError extends StateError {
  FileReadError(String message) : super(message);
}
