import 'dart:io';

import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

Future<Dataset> loader({
  required String title,
  String fileSubstring = '',
  String filename = '',
  required int numHeaderLines,
  required Transaction Function(String) parseToTransaction,
  required bool Function(Transaction) filter,
}) async {
  assert(
    fileSubstring.isEmpty ^ filename.isEmpty,
    'You must provide fileSubstring XOR filename. $fileSubstring $filename',
  );
  final List<File> files = await Directory('/Users/Ethan/Downloads')
      .list()
      .map((file) => File(file.path))
      .where((file) => fileSubstring.isEmpty
          ? file.basename == filename
          : file.path.contains(fileSubstring))
      .toList();
  assert(
    files.length == 1,
    'ERROR: Files matching $fileSubstring for $title: ${files.length}',
  );
  final File dumpCsv = files.first;
  print('Parsing $title dump from ${dumpCsv.basename}');
  final String dumpContents = await dumpCsv.readAsString();
  final Iterable<Transaction> txns = dumpContents
      .split('\n')
      .skip(numHeaderLines)
      .where((line) => line.isNotEmpty)
      .map(parseToTransaction)
      .where(filter);
  return Dataset(txns);
}
