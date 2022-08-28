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
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(selectedCategoriesProvider);
    final eligibleTxns = _eligibleTxns();
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(12),
      elevation: 6,
      child: Column(
        children: [
          Header(textEditingController, eligibleTxns),
          Expanded(
            child: ListView(
              children: eligibleTxns.transactions.mapL(_listTile),
            ),
          ),
        ].separatedBy(const SizedBox(height: 10)),
      ),
    );
  }

  Dataset _eligibleTxns() {
    return Dataset(
      widget.dataset
          .forCategories(ref.read(selectedCategoriesProvider.notifier))
          .transactions
          .sortOn((txn) => -txn.amount.abs())
          .where(
            (txn) =>
                textEditingController.text.isEmpty ||
                txn.title.contains(textEditingController.text),
          )
          .toList(),
    );
  }

  Widget _listTile(Transaction txn) {
    return ListTile(
      leading: Text(
        '${txn.amount.asCompactDollars()}',
        style: TextStyle(
          color: txn.amount < 0 ? Colors.green : Colors.red,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Text(txn.date.formatted),
      isThreeLine: true,
      subtitle: _subtitle(txn),
      title: Text(
        txn.title,
        style: TextStyle(
          color: txn.amount < 0 ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  Widget _subtitle(Transaction txn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${txn.txnType}'),
        Text('${txn.category}'),
      ],
    );
  }
}

class Header extends StatelessWidget {
  const Header(this.textEditingController, this.shownTxns);

  final TextEditingController textEditingController;

  final Dataset shownTxns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 12, top: 12, bottom: 6),
      decoration: _roundedBottom(),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transactions review', style: titleStyle),
            _totalEarnedOrSpent(),
          ],
        ),
        _searchBar(),
      ]),
    );
  }

  Decoration _roundedBottom() {
    return BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          blurStyle: BlurStyle.outer,
          blurRadius: 2,
          spreadRadius: 0,
          offset: Offset(0, 1),
        ),
      ],
      color: Colors.grey[800],
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

  // TODO(feature): Move this to *a new [FilterCard Widget]*, which _also_ has
  //  the [Category FilterChips], which applies *across the whole app*,
  //  including eg. the line chart, bar charts, and "txns review" list.
  //
  // Plan:
  //
  // 1) Refactor the controller to be an app-level ValueNotifierProvider via
  //    RiverPods.
  //
  //    -> Cleanup: This probably means its widget can be stateless now.
  //
  // 2) Plug all the different cards into the list of txns filtered via the
  //    search bar controller.
  //
  //    -> Impl note: This probably means the Dataset StateNotifier should have
  //    the search bar controller run as a pre-filter configured upon it, if you
  //    remember what I mean; it's a slightly more advanced usage of the
  //    riverpod library.
  //
  // 3) Plug the Category FilterChips into all the different cards too. Ensuring
  //    it is INTERSECTION with the SearchBar text filter.
  //
  // 4) Create the new FilterCard widget, with this SearchBar inside of it, and
  //    with the Category FilterChips inside it too.
  //
  Widget _searchBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 16),
        child: Row(children: [
          Expanded(
            child: TextFormField(
              controller: textEditingController,
            ),
          ),
          Icon(Icons.search, color: Colors.lightBlue[200]),
        ]),
      ),
    );
  }
}
