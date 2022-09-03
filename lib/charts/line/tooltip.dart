import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';

import 'line.dart';

// TODO(feature): Show txns from the surrounding dates in the tooltip.
class MyTooltip {
  static LineTouchData create(List<Line> lines) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        maxContentWidth: 200, // default is 120.
        tooltipBgColor: Colors.grey[800]!.withOpacity(.8),
        tooltipBorder: BorderSide(
          color: Colors.black.withOpacity(.4),
          width: 2,
        ),

        // Make tooltip hug inside of top of chart.
        showOnTopOfTheChartBoxArea: true,
        fitInsideVertically: true,

        getTooltipItems: (touchedSpots) => touchedSpots.mapL((touchedSpot) {
          final line = lines[touchedSpot.barIndex];
          return LineTooltipItem(
            '${line.title}: ${touchedSpot.y.asCompactDollars()}',
            TextStyle(color: line.color),
            // Chart library dictates that #tooltip_items == #touched_spots, so
            //  to show the date as a separate line, we append it to the last
            //  tooltip.
            children: [
              if (touchedSpot == touchedSpots.last) // yes it's equatable.
                TextSpan(
                  text: '\nDate: ${touchedSpots.first.x.toDate.formatted}',
                  style: const TextStyle(color: Colors.white60),
                ),
            ],
          );
        }),
      ),
    );
  }
}
