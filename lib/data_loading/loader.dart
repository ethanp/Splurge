import 'dart:io';

import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

Future<Dataset> loader({
  required String title,
  required String fileSubstring,
  required int numHeaderLines,
  required Transaction Function(String) parseToTransaction,
  required bool Function(Transaction) filter,
}) async {
  final Stream<FileSystemEntity> downloads =
      Directory('/Users/Ethan/Downloads').list();
  final List<FileSystemEntity> matchingFiles = await downloads
      .where((file) => file.path.contains(fileSubstring))
      .toList();
  assert(matchingFiles.length == 1,
      'matching file count for $title: ${matchingFiles.length}');
  final File dumpCsv = matchingFiles.first as File;
  print('Parsing $title dump from ${dumpCsv.basepath}');
  final String dumpContents = await dumpCsv.readAsString();
  final Iterable<Transaction> txns = dumpContents
      .split('\n')
      .skip(numHeaderLines)
      .where((line) => line.isNotEmpty)
      .map(parseToTransaction)
      .where(filter);
  return Dataset(txns);
}

// TODO(feature): Also figure out how much has been *deposited* into the
//  different *investment* accounts (eg. coinbase, WealthFront, m1). I'm
//  guessing Perscap would be more complete for this, but do check first.
