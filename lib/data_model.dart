class Dataset {
  const Dataset(this.transactions);

  final List<Transaction> transactions;

  Iterable<Transaction> get spendingTxns =>
      transactions.where((t) => t.txnType == 'regular');
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
