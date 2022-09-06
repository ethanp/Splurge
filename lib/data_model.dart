import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class Dataset {
  const Dataset(this.transactions);

  final List<Transaction> transactions;

  int get count => transactions.length;

  bool get isEmpty => transactions.isEmpty;

  Transaction? get maybeLastTxn => transactions.maybeLast;

  Transaction get lastTxn => transactions.last;

  Dataset get spendingTxns => Dataset(transactions.whereL(
      (t) => t.category != 'income' && t.category != 'internal transfer'));

  Dataset get incomeTxns =>
      Dataset(transactions.whereL((t) => t.category == 'income'));

  List<MapEntry<String, Dataset>> get txnsByMonth =>
      transactions.fold([], (accumulator, txn) {
        final month = txn.date.month;
        final prevItemMonth =
            accumulator.maybeLast?.value.maybeLastTxn?.date.month;

        if (month == prevItemMonth)
          accumulator.last.value.transactions.add(txn);
        else
          accumulator.add(MapEntry(txn.date.monthString, Dataset([txn])));

        return accumulator;
      });

  List<MapEntry<String, Dataset>> get txnsByQuarter => txnsByMonth
          .map((_) => _.value)
          .fold<List<Dataset>>([], (accumulator, dataset) {
        if (dataset.lastTxn.date.qtr ==
            accumulator.maybeLast?.maybeLastTxn?.date.qtr)
          accumulator.last.transactions.addAll(dataset.transactions);
        else
          accumulator.add(dataset);

        return accumulator;
      }).mapL(
        (value) => MapEntry(
          value.transactions.first.date.qtrString,
          value,
        ),
      );

  double get totalAmount => transactions.sumBy((txn) => txn.amount);

  Dataset forCategories(SelectedCategories selectedCategories) =>
      Dataset(transactions.whereL((txn) => selectedCategories.includes(txn)));
}

class Transaction {
  const Transaction({
    required this.date,
    required this.title,
    required this.amount,
    required this.category,
  });

  final DateTime date;
  final String title;
  final double amount;
  final String category;

  @override
  String toString() => ''
      '${date.formatted}, '
      '$title, '
      '$amount, '
      '${category.isEmpty ? 'no category' : category}';
}
