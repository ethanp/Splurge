import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class FilterCard extends ConsumerStatefulWidget {
  @override
  FilterCardState createState() => FilterCardState();
  static final cardColor = Colors.brown[900];
  static final chipTextStyle = GoogleFonts.aBeeZee();
}

class FilterCardState extends ConsumerState<FilterCard> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Riverpod does not allow putting reads of providers in initState(); it has
    // to be in didChangeDependencies().
    textEditingController.addListener(() => ref
        .read(TextFilter.provider.notifier)
        .checkFor(textEditingController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: Shape.roundedRect(circular: 20),
      color: FilterCard.cardColor,
      elevation: 4,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: _searchBar(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _CategoryChips(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: _TimeRangeSelector(),
        ),
      ]),
    );
  }

  Widget _searchBar() {
    final txns = ref.watch(DatasetNotifier.filteredProvider);
    final isActive = ref.watch(TextFilter.provider).isNotEmpty;
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: 'Enter search text',
        helperText: '${txns.numTxns} matches',
        labelText: 'Filter transactions by title',
        counterText: isActive
            ? 'Filter is active'
            : 'Filter is inactive (search is empty)',
        counterStyle: TextStyle(
          color: isActive ? Colors.green : Colors.grey[600],
        ),
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Icon(
            Icons.search,
            size: 40,
            color: Colors.blueGrey[400]!.withBlue(140),
          ),
        ),
        suffixIcon: _clearFieldButton(),
      ),
    );
  }

  Widget _clearFieldButton() {
    return IconButton(
      padding: const EdgeInsets.only(right: 4),
      onPressed: () => textEditingController.clear(),
      icon: Icon(
        Icons.clear,
        size: 36,
        color: Colors.red.withOpacity(.6),
      ),
    );
  }
}

/// Note: I've tried to make the larger chips' fontSize shrink when it exceeds
/// 2 rows in the Wrap, but concluded that it is not possible without
/// reimplementing the `AutoSizeText` in a different way.
class _CategoryChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullDataset = ref.watch(DatasetNotifier.unfilteredProvider);

    return Wrap(
      runSpacing: 8,
      children: [
        _categorySection(
          title: 'Income',
          color: Colors.blueGrey[300]!.withGreen(200),
          categoryNames: fullDataset.incomeCategories,
        ),
        _categorySection(
          title: 'Spending',
          color: Colors.blueGrey[300]!.withRed(200),
          categoryNames: fullDataset.spendingCategories,
        ),
      ],
    );
  }

  Widget _categorySection({
    required String title,
    required Color color,
    required Iterable<String> categoryNames,
  }) {
    return Stack(
      children: [
        _roundedRect(child: _chips(categoryNames)),
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          color: FilterCard.cardColor,
          child: Text(
            title,
            style: GoogleFonts.robotoSlab(
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chips(Iterable<String> names) {
    return Wrap(
      spacing: 4,
      runSpacing: 5,
      children: [
        _AllChip(names),
        ...names.map(_CategoryChip.new),
      ],
    );
  }

  Widget _roundedRect({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

class _TimeRangeSelector extends ConsumerStatefulWidget {
  @override
  TimeRangeSelectorState createState() => TimeRangeSelectorState();
}

class TimeRangeSelectorState extends ConsumerState<_TimeRangeSelector> {
  var selectedButton = 0;

  @override
  Widget build(BuildContext context) {
    final selectedDateRange = ref.read(SelectedDateRange.provider.notifier);
    return Wrap(
      spacing: 4,
      children: [
        _button(
          text: 'All time',
          onPressed: () => selectedDateRange.reset(),
        ),
        _button(
          text: 'Prior 3 months',
          onPressed: () => selectedDateRange.priorMonths(3),
        ),
        ...Iterable.generate(
          /* numYears = */ DateTime.now().year - 2020,
          (index) {
            final year = 2021 + index;
            return _button(
              text: year.toString(),
              onPressed: () => selectedDateRange.setRange(
                DateRange.just(year: year, atMostNow: true),
              ),
            );
          },
        ),
        _button(
          // TODO(feature): This should really be "set date range" like the
          //  flights.google.com date range picker.
          text: 'Set start date',
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDateRange.range.start,
              firstDate: DateTime(2020, 12),
              lastDate: DateTime.now(),
            );
            if (picked == null || picked == selectedDateRange.range.start)
              return; // no change.
            selectedDateRange.setStart(picked);
          },
        ),
      ].mapWithIdx((createButton, idx) => createButton(idx)).toList(),
    );
  }

  Widget Function(int) _button({
    required String text,
    required VoidCallback onPressed,
  }) =>
      (int idx) {
        final selectedStyle = ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
        final unselectedStyle = selectedStyle.copyWith(
          backgroundColor: MaterialStatePropertyAll(Colors.blueGrey),
        );
        return ElevatedButton(
          style: selectedButton == idx ? selectedStyle : unselectedStyle,
          onPressed: () {
            setState(() => selectedButton = idx);
            onPressed();
          },
          child: Text(text),
        );
      };
}

/// Simple way to allow the user to analyze by EXCLUDING categories.
class _AllChip extends ConsumerWidget {
  const _AllChip(this.allCategories);

  final Iterable<String> allCategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(SelectedCategories.provider);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);

    return FilterChip(
      label: Text('All', style: FilterCard.chipTextStyle),
      shape: Shape.roundedRect(circular: 10),
      backgroundColor: Colors.blue[800],
      selectedColor: Colors.blue[300],
      // This way the chip doesn't ever change size.
      showCheckmark: false,
      selected: selectedCategories.containsAll(allCategories),
      onSelected: (bool? isSelected) {
        if (isSelected ?? false)
          selectedCategories.addAll(allCategories);
        else
          selectedCategories.clear();
      },
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  const _CategoryChip(this.category);

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(SelectedCategories.provider);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);

    return FilterChip(
      padding: EdgeInsets.zero,
      shape: Shape.roundedRect(circular: 10),
      // This way the chip doesn't ever change size.
      showCheckmark: false,
      selectedColor: category.isIncome ? Colors.green[700] : Colors.red[600],
      label: Text(category, style: FilterCard.chipTextStyle),
      selected: selectedCategories.contains(category),
      onSelected: (bool? isSelected) {
        if (isSelected ?? false)
          selectedCategories.add(category);
        else
          selectedCategories.remove(category);
      },
    );
  }
}
