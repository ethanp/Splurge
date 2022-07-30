import 'package:splurge/util/extensions.dart';

class Dataset {
  const Dataset(this.transactions);

  final List<Transaction> transactions;

  Transaction? get maybeLast => transactions.maybeLast;
  Transaction get last => transactions.last;

  Dataset get spendingTxns =>
      Dataset(transactions.where((t) => t.txnType == 'regular').toList());

  List<Dataset> get txnsByMonth => transactions.fold([], (accumulator, txn) {
        final month = txn.date.month;
        final prevItemMonth = accumulator.maybeLast?.maybeLast?.date.month;

        if (month == prevItemMonth)
          accumulator.last.transactions.add(txn);
        else
          accumulator.add(Dataset([txn]));

        return accumulator;
      });

  List<Dataset> get txnsByQuarter => txnsByMonth.fold([], (accumulator, txns) {
        int quarter(Transaction? txn) => txn?.date.qtr ?? 0;

        if (quarter(txns.last) == quarter(accumulator.maybeLast?.maybeLast))
          accumulator.last.transactions.addAll(txns.transactions);
        else
          accumulator.add(txns);

        return accumulator;
      });

  double get totalAmount => transactions.sumBy((txn) => txn.amount);
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
  String toString() => 'Transaction('
      'date: $date, '
      'title: $title, '
      'amount: $amount, '
      'category: $category, '
      'txnType: $txnType'
      ')';
}
