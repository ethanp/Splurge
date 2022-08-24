import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

class Dataset {
  const Dataset(this.transactions);

  final List<Transaction> transactions;

  Transaction? get maybeLastTxn => transactions.maybeLast;
  Transaction get lastTxn => transactions.last;

  Dataset get spendingTxns =>
      Dataset(transactions.where((t) => t.txnType == 'regular').toList());

  Dataset get incomeTxns =>
      Dataset(transactions.where((t) => t.txnType == 'income').toList());

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

  Dataset forCategories(SelectedCategories selectedCategories) => Dataset(
      transactions.where((txn) => selectedCategories.includes(txn)).toList());
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
