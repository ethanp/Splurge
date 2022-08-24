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
    final largestTxns = dataset
        .forCategories(selectedCategories)
        .transactions
        .sortOn((txn) => -txn.amount.abs())
        .take(50);

    return Column(children: [
      Text('Largest transactions review', style: titleStyle),
      Expanded(
        child: ListView(
          children: [
            for (final txn in largestTxns)
              ListTile(
                title: Text(
                  '$txn',
                  style: TextStyle(
                    color: txn.amount < 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}
