import 'dart:io';

import 'package:splurge/global/data_model.dart';

Future<Dataset> loader({
  required String title,
  required String fileSubstring,
  required int numHeaderLines,
  required Transaction Function(String) f,
  required bool Function(Transaction) filter,
}) async {
  final Stream<FileSystemEntity> downloads =
      Directory('/Users/Ethan/Downloads').list();
  final FileSystemEntity dumpCsv =
      await downloads.firstWhere((f) => f.path.contains(fileSubstring));
  print('Parsing $title dump');
  final String dumpContents = await (dumpCsv as File).readAsString();
  final Iterable<Transaction> txns =
      dumpContents.split('\n').skip(numHeaderLines).map(f).where(filter);
  return Dataset(txns);
}

// TODO(feature): Also figure out how much has been *deposited* into the
//  different *investment* accounts (eg. coinbase, WealthFront, m1). I'm
//  guessing Perscap would be more complete for this, but do check first.
