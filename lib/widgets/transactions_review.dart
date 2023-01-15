import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/global/style.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

import 'header.dart';

class LargestTransactions extends ConsumerStatefulWidget {
  @override
  LargestTransactionsState createState() => LargestTransactionsState();
}

class LargestTransactionsState extends ConsumerState<LargestTransactions> {
  @override
  Widget build(BuildContext context) {
    ref.watch(SelectedCategories.provider);
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.grey[900],
      elevation: 18,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(100),
          right: Radius.elliptical(120, 90),
        ),
      ),
      child: Stack(children: [
        _transactionList(),
        Header('Matching transactions'),
      ]),
    );
  }

  Widget _transactionList() {
    final dataset = ref.watch(DatasetNotifier.filteredProvider);
    final textFilter = ref.read(TextFilter.provider.notifier);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);
    final filters = [textFilter, selectedCategories];

    final eligibleTxns =
        dataset.where((txn) => filters.all((filter) => filter.includes(txn)));

    final listView = ListView.builder(
      itemCount: eligibleTxns.count + 1,
      itemBuilder: (_, idx) {
        if (idx == 0) {
          // Add one blank spot to the top to match spacing behind the Header.
          return const SizedBox(height: 50);
        } else {
          return _ListTile(eligibleTxns.txns[idx - 1]);
        }
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: listView,
    );
  }
}

// TODO(UX): Make this a TableView instead so that the user can choose which
//  column to filter by, and so that each column will have the same width.
class _ListTile extends StatelessWidget {
  const _ListTile(this.txn);

  final Transaction txn;

  @override
  Widget build(BuildContext context) {
    final amount = Text(
      txn.amount.abs().asCompactDollars(),
      textAlign: TextAlign.right,
      style: appFont.copyWith(
        color: txn.amount < 0 ? Colors.green : Colors.red,
        fontSize: 18,
      ),
    );
    final title = AutoSizeText(
      txn.title,
      maxLines: 2,
      style: appFont.copyWith(
        color: txn.amount < 0 ? Colors.green : Colors.red,
        fontSize: 17,
      ),
    );
    final category = Text(
      txn.category,
      style: appFont.copyWith(
        color: Colors.blueGrey[300],
        fontSize: 14,
      ),
    );
    final date = Text(
      txn.date.formatted,
      style: appFont.copyWith(
        color: Colors.blueGrey[400],
      ),
    );

    return Card(
      color: Colors.black87.withOpacity(.2),
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      child: Row(
        children: <Widget>[
          Expanded(child: amount),
          Expanded(flex: 2, child: title),
          Expanded(child: category),
          Expanded(child: date),
        ].separatedBy(const SizedBox(width: 30, height: 40)),
      ),
    );
  }
}
