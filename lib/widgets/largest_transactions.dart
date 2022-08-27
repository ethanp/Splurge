import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';
import 'package:splurge/util/widgets.dart';

class LargestTransactions extends ConsumerWidget {
  const LargestTransactions({required this.dataset});

  final Dataset dataset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedCategoriesProvider);
    final selectedCategories = ref.read(selectedCategoriesProvider.notifier);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.all(12),
      elevation: 6,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 18, bottom: 12, top: 8),
            color: Colors.grey[800],
            child: Row(children: [
              Text(
                'Largest transactions review',
                style: titleStyle,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 32, right: 10),
                  child: SearchBar(),
                ),
              ),
            ]),
          ),
          Expanded(
            child: ListView(
              children: dataset
                  .forCategories(selectedCategories)
                  .transactions
                  .sortOn((txn) => -txn.amount.abs())
                  .take(50)
                  .mapL(_listTile),
            ),
          ),
        ].separatedBy(const SizedBox(height: 10)),
      ),
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

class SearchBar extends StatelessWidget {
  // TODO(feature): filter the list based on the value within this.
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: TextFormField(
            controller: textEditingController,
          ),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(
            Icons.search,
            color: Colors.lightBlue[200],
          ),
        ),
      ],
    );
  }
}
