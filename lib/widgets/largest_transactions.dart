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

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(12),
      elevation: 6,
      child: Column(
        children: [
          Header(textEditingController),
          Expanded(child: _txnList()),
        ].separatedBy(const SizedBox(height: 10)),
      ),
    );
  }

  Widget _txnList() {
    return ListView(
      children: widget.dataset
          .forCategories(ref.read(selectedCategoriesProvider.notifier))
          .transactions
          .sortOn((txn) => -txn.amount.abs())
          .where(
            (txn) =>
                textEditingController.text.isEmpty ||
                txn.title.contains(textEditingController.text),
          )
          .take(50)
          .mapL(_listTile),
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
  const Header(this.textEditingController);

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18, bottom: 12, top: 8),
      decoration: BoxDecoration(
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
      ),
      child: Row(children: [
        Text('Largest transactions review', style: titleStyle),
        _searchBar(),
      ]),
    );
  }

  Widget _searchBar() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 10),
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
