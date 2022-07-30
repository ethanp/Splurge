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
              FutureBuilder<List<List<String>>>(
                future: CopilotExportReader.loadData,
                builder: (ctx, snapshot) => snapshot.hasData
                    ? Text(snapshot.data!.length.toString())
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
  static Future<List<List<String>>> get loadData async {
    try {
      final file = File('/Users/Ethan/Downloads/transactions.csv');
      print('Reading in the file');
      final contents = await file.readAsString();
      print('Parsing the file');
      return _parse(contents);
    } catch (e) {
      throw FileReadError('Uh oh! $e');
    }
  }

  static List<List<String>> _parse(String filetext) {
    return filetext
        .split('\n')
        .skip(1) // Skip header.
        .map(_cleanup)
        .map((line) => line.split(','))
        .toList();
  }

  static String _cleanup(String line) => line;
}

class FileReadError extends StateError {
  FileReadError(String message) : super(message);
}
