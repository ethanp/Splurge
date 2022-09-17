import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class Dataset {
  const Dataset(this.txns);

  final List<Transaction> txns;

  int get count => txns.length;

  bool get isEmpty => txns.isEmpty;

  Transaction? get maybeLastTxn => txns.maybeLast;

  Transaction get lastTxn => txns.last;

  Dataset get spendingTxns => Dataset(txns.whereL(
      (t) => t.txnType != 'income' && t.txnType != 'internal transfer'));

  Dataset get incomeTxns => Dataset(txns.whereL((t) => t.txnType == 'income'));

  List<MapEntry<String, Dataset>> get txnsByMonth =>
      txns.fold([], (accumulator, txn) {
        final month = txn.date.month;
        final prevItemMonth =
            accumulator.maybeLast?.value.maybeLastTxn?.date.month;

        if (month == prevItemMonth)
          accumulator.last.value.txns.add(txn);
        else
          accumulator.add(MapEntry(txn.date.monthString, Dataset([txn])));

        return accumulator;
      });

  List<MapEntry<String, Dataset>> get txnsByQuarter => txnsByMonth
          .map((_) => _.value)
          .fold<List<Dataset>>([], (accumulator, dataset) {
        if (dataset.lastTxn.date.qtr ==
            accumulator.maybeLast?.maybeLastTxn?.date.qtr)
          accumulator.last.txns.addAll(dataset.txns);
        else
          accumulator.add(dataset);

        return accumulator;
      }).mapL(
        (value) => MapEntry(
          value.txns.first.date.qtrString,
          value,
        ),
      );

  double get totalAmount => txns.sumBy((txn) => txn.amount);

  Dataset forCategories(SelectedCategories selectedCategories) =>
      Dataset(txns.whereL((txn) => selectedCategories.includes(txn)));
}

class Transaction {
  const Transaction({
    required this.date,
    required this.title,
    required this.amount,
    required this.category,
    required this.txnType,
  });

  final DateTime date;
  final String title;
  final double amount;
  final String category;
  final String txnType;

  @override
  String toString() => ''
      '${date.formatted}, '
      '$title, '
      '$amount, '
      '${category.isEmpty ? 'no category' : category}, '
      '$txnType';
}
