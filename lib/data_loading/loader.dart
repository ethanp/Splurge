import 'dart:io';

import 'package:splurge/global/data_model.dart';
import 'package:splurge/util/errors.dart';

Future<Dataset> loader({
  required String title,
  required String fileSubstring,
  required int numHeaderLines,
  required Transaction Function(String) f,
  required bool Function(Transaction) filter,
}) async {
  try {
    final downloads = Directory('/Users/Ethan/Downloads').list();
    final dumpCsv =
        await downloads.firstWhere((f) => f.path.contains(fileSubstring));
    print('Parsing $title dump');
    final dumpContents = await (dumpCsv as File).readAsString();
    final txns =
        dumpContents.split('\n').skip(numHeaderLines).map(f).where(filter);
    return Dataset(txns);
  } on Error catch (e) {
    print(e.stackTrace);
    throw FileReadError('Perscap parse issue! $e');
  }
}
