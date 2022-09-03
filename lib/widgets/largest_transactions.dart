import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';
import 'package:splurge/util/widgets.dart';

class LargestTransactions extends ConsumerStatefulWidget {
  const LargestTransactions({required this.dataset});

  final Dataset dataset;

  @override
  LargestTransactionsState createState() => LargestTransactionsState();
}

class LargestTransactionsState extends ConsumerState<LargestTransactions> {
  @override
  void initState() {
    super.initState();
    _textFilter.addListener(() => setState(() {}));
  }

  TextFilter get _textFilter => ref.read(TextFilter.provider.notifier);

  @override
  Widget build(BuildContext context) {
    ref.watch(SelectedCategories.provider);
    final eligibleTxns = _eligibleTxns();
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(100),
          right: Radius.elliptical(120, 90),
        ),
      ),
      margin: const EdgeInsets.all(12),
      elevation: 18,
      child: Stack(children: <Widget>[
        _txnListView(eligibleTxns),
        Header(eligibleTxns),
      ]),
    );
  }

  Dataset _eligibleTxns() {
    return Dataset(
      widget.dataset
          .forCategories(ref.read(SelectedCategories.provider.notifier))
          .transactions
          .sortOn((txn) => -txn.amount.abs())
          .where((txn) => _textFilter.includes(txn))
          .toList(),
    );
  }

  Widget _txnListView(Dataset eligibleTxns) {
    return Positioned(
      top: 20,
      height: 600,
      width: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 12,
        ),
        child: ListView.builder(
          itemCount: eligibleTxns.count + 1,
          itemBuilder: (_, idx) => idx == 0
              // We need one blank spot to allow it to go behind the Header.
              ? const SizedBox(height: 54)
              : _listTile(eligibleTxns.transactions[idx - 1]),
        ),
      ),
    );
  }

  Widget _listTile(Transaction txn) {
    return ListTile(
      leading: Text(
        txn.amount.asCompactDollars(),
        style: TextStyle(
          color: txn.amount < 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Text(txn.date.formatted),
      isThreeLine: true,
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(txn.txnType), Text(txn.category)],
      ),
      title: Text(
        txn.title,
        style: TextStyle(
          color: txn.amount < 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.shownTxns);

  final Dataset shownTxns;

  @override
  Widget build(BuildContext context) {
    return _headerCard(
      content: Row(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transactions review', style: titleStyle),
            _totalEarnedOrSpent(),
          ],
        ),
      ]),
    );
  }

  Widget _headerCard({required Widget content}) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.4, sigmaY: 4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.elliptical(40, 20),
              bottomRight: Radius.elliptical(40, 20),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.brown,
                Colors.brown.withOpacity(.4),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _totalEarnedOrSpent() {
    final earnedOrSpent = shownTxns.totalAmount.isNegative ? 'Earned' : 'Spent';
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 0, left: 2),
      child: RichText(
        text: TextSpan(
          style: appFont.copyWith(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey[400],
          ),
          children: [
            TextSpan(text: 'Total $earnedOrSpent: '),
            TextSpan(
              text: shownTxns.totalAmount.abs().asCompactDollars(),
              style: TextStyle(
                color: !shownTxns.totalAmount.isNegative
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
