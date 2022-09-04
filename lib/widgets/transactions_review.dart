import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';
import 'package:splurge/util/style.dart';

class LargestTransactions extends ConsumerStatefulWidget {
  const LargestTransactions({required this.dataset});

  final Dataset dataset;

  @override
  LargestTransactionsState createState() => LargestTransactionsState();
}

class LargestTransactionsState extends ConsumerState<LargestTransactions> {
  TextFilter get _textFilter => ref.read(TextFilter.provider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.watch(SelectedCategories.provider);
    final eligibleTxns = _eligibleTxns();
    return Card(
      color: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(100),
          right: Radius.elliptical(120, 90),
        ),
      ),
      margin: const EdgeInsets.all(12),
      elevation: 18,
      child: Stack(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            itemCount: eligibleTxns.count + 1,
            itemBuilder: (_, idx) => idx == 0
                // Add one blank spot to allow it to go behind the Header.
                ? const SizedBox(height: 24)
                : _listTile(eligibleTxns.transactions[idx - 1]),
          ),
        ),
        Header(eligibleTxns),
      ]),
    );
  }

  Dataset _eligibleTxns() => Dataset(widget.dataset
      .forCategories(ref.read(SelectedCategories.provider.notifier))
      .transactions
      .sortOn((txn) => -txn.amount.abs())
      .whereL((txn) => _textFilter.includes(txn)));

  // TODO(UX): Make this a TableView instead so that the user can choose which
  //  column to filter by, and so that each column will have the same width.
  Widget _listTile(Transaction txn) {
    final amount = Text(
      txn.amount.asCompactDollars(),
      textAlign: TextAlign.right,
      style: appFont.copyWith(
        color: Colors.grey,
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
      txn.txnType == 'regular' ? txn.category : txn.txnType,
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

class Header extends StatelessWidget {
  const Header(this.shownTxns);

  final Dataset shownTxns;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 4),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(40, 20),
              bottomRight: Radius.elliptical(40, 20),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.brown, Colors.brown.withOpacity(.4)],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              // The below performs: `this.height = child.height * 2`
              heightFactor: 2,
              child: Text('Matching transactions', style: titleStyle),
            ),
          ),
        ),
      ),
    );
  }
}
