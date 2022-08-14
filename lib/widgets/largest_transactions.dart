import 'package:flutter/material.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/widgets.dart';

class LargestTransactions extends StatelessWidget {
  const LargestTransactions({required this.dataset});

  final Dataset dataset;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Largest transactions review', style: titleStyle),
      Expanded(
        child: ListView(
          children: dataset.transactions
              .sortOn((txn) => -txn.amount.abs())
              .take(50)
              .mapL(
                (txn) => ListTile(
                  title: Text(
                    '$txn',
                    style: TextStyle(
                      color: txn.amount < 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
        ),
      ),
    ]);
  }
}
