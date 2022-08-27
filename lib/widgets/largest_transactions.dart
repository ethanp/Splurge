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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('Largest transactions review', style: titleStyle),
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
          ],
        ),
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
