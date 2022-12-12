// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class Dataset {
  Dataset(Iterable<Transaction> txns) {
    this.txns = txns.toList().sortOn((_) => _.date);
  }

  factory Dataset.merge(Iterable<Dataset?> datasets) =>
      Dataset(datasets.expand((dataset) => dataset?.txns ?? []));

  /// By default, always sorted by date.
  late final List<Transaction> txns;

  int get count => txns.length;

  bool get isEmpty => txns.isEmpty;

  Transaction? get maybeLastTxn => txns.maybeLast;

  Transaction get lastTxn => txns.last;

  Dataset get spendingTxns => where((txn) => txn.isSpending);

  Dataset get incomeTxns => where((txn) => txn.isIncome);

  Set<String> get categories => txns.map((txn) => txn.category).toSet();

  Map<String, Dataset> get txnsPerCategory => txns
      .groupBy((txn) => txn.category)
      .map((cat, txns) => MapEntry(cat, Dataset(txns)));

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

  List<MapEntry<String, Dataset>> get txnsByQuarter =>
      txnsByMonth.map((_) => _.value).fold<List<Dataset>>(
        [],
        (quartersSoFar, dataset) {
          if (dataset.lastTxn.date.qtr ==
              quartersSoFar.maybeLast?.maybeLastTxn?.date.qtr)
            quartersSoFar.last.txns.addAll(dataset.txns);
          else
            quartersSoFar.add(dataset);

          return quartersSoFar;
        },
      ).mapL((value) => MapEntry(value.txns.first.date.qtrString, value));

  double get totalAmount => txns.sumBy((txn) => txn.amount);

  Dataset forCategories(SelectedCategories selectedCategories) =>
      where((txn) => selectedCategories.includes(txn));

  Dataset where(bool Function(Transaction) f) => Dataset(txns.where(f));
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

  bool get isSpending => !category.isIncome && txnType != 'internal transfer';

  bool get isIncome => category.isIncome;

  @override
  String toString() => ''
      '${date.formatted}, '
      '$title, '
      '$amount, '
      '${category.isEmpty ? 'no category' : category}, '
      '$txnType';

  /// Range has [this, shape).
  bool isWithinDateRange(DateTimeRange range) =>
      date.isAtLeast(range.start) && date.isBefore(range.end);
}

enum IncomeCategory {
  // That ~biweekly paycheck.
  Payroll,
  // Includes spot & annual bonuses.
  Bonus,
  // Amount of cash I got from a transfer from brokerage account.
  GSUs,
  // Contribution into a tax-advantaged account, eg. 401(k), IRA, or HSA.
  TaxAdvContrib,
  // Eg. cash-out of life insurance.
  Random,
  // Money I pay to govt, beyond what was taken on the way to me.
  Taxes;
}

extension IncomeCat on String {
  bool get isIncome => IncomeCategory.values.any((i) => i.name == this);
}
