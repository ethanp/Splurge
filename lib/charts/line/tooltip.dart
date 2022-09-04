import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

import 'line.dart';

class MyTooltip {
  static LineTouchData create(List<Line> lines, Dataset dataset) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        // Default max content width is 120.
        maxContentWidth: 250,
        tooltipBgColor: Colors.grey[800]!.withOpacity(.8),
        tooltipBorder: BorderSide(
          color: Colors.black.withOpacity(.4),
          width: 2,
        ),

        // Make tooltip hug inside of top of chart.
        showOnTopOfTheChartBoxArea: true,
        fitInsideVertically: true,

        getTooltipItems: (touchedSpots) {
          final date = touchedSpots.first.x.toDate;
          final txns = Dataset(dataset.transactions
              .whereL((e) => e.date.formatted == date.formatted));
          final txnsStr = txns.transactions
              .map((t) => '${t.amount.asCompactDollars()} ${t.title}')
              .join('\n');
          final lastSpot = [
            TextSpan(
              text: '\nDate: ${date.formatted}',
              style: const TextStyle(color: Colors.white60),
            ),
            TextSpan(
              text: '\n\nThis day\'s txns:\n$txnsStr',
              style: const TextStyle(color: Colors.white60),
            ),
          ];
          return touchedSpots.mapL((touchedSpot) {
            final line = lines[touchedSpot.barIndex];
            return LineTooltipItem(
              '${line.title}: ${touchedSpot.y.asCompactDollars()}',
              TextStyle(color: line.color),
              // Chart library dictates that #tooltip_items == #touched_spots, so
              //  to show the date as a separate line, we append it to the last
              //  tooltip. Yes, the touched spots are [Equatable].
              children: [if (touchedSpot == touchedSpots.last) ...lastSpot],
            );
          });
        },
      ),
    );
  }
}
