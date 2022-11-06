import 'package:flutter/material.dart';

class AnnualCategorySummaryPage extends StatelessWidget {
  const AnnualCategorySummaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table of annualized spending per category per year'),
      ),
      // TODO(feature): Table of annualized spending per category per year.
      body: Table(
        children: const [
          TableRow(
            children: [
              Text('hello'),
              Text('hello'),
              Text('hello'),
              Text('hello'),
            ],
          ),
          TableRow(
            children: [
              Text('hello2'),
              Text('hello2'),
              Text('hello2'),
              Text('hello2'),
            ],
          ),
        ],
      ),
    );
  }
}
