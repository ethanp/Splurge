import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/global/data_model.dart';
import 'package:splurge/global/providers.dart';
import 'package:splurge/util/extensions/stdlib_extensions.dart';

class FilterCard extends ConsumerStatefulWidget {
  @override
  FilterCardState createState() => FilterCardState();
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
    // TODO(UI): Consider using ConstrainedBox or something to let this resize
    //  itself to some extent; since I can't find a single size that looks good
    //  on both laptop and big monitor. Specifically, the card should get taller
    //  as it gets skinnier, to still fit all the chips.
    return SizedBox(
      height: 330,
      width: 510,
      child: Card(
        shape: Shape.roundedRect(circular: 20),
        color: Colors.brown[900],
        elevation: 4,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 6,
            ),
            child: _searchBar(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _categoryChips(),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: _TimeRangeSelector(),
          ),
        ]),
      ),
    );
  }

  Widget _searchBar() {
    final txns = ref.watch(DatasetNotifier.filteredProvider);
    final isActive = ref.watch(TextFilter.provider).isNotEmpty;
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: 'Enter search text',
        helperText: '${txns.count} matches',
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

  Widget _categoryChips() {
    final fullDataset = ref.read(DatasetNotifier.unfilteredProvider);
    final allCategories = fullDataset.txns.map((txn) => txn.category).toSet();
    bool isIncome(String category) => category.isIncome;

    return Wrap(
      runSpacing: 8,
      children: [
        _categorySection(allCategories.where(isIncome)),
        _categorySection(allCategories.where(isIncome.inverted)),
      ],
    );
  }

  Widget _categorySection(Iterable<String> categories) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Wrap(
        spacing: 3,
        runSpacing: 4,
        children: [
          _AllChip(categories),
          ...categories.map(_CategoryChip.new),
        ],
      ),
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
    final thisYear = DateTime.now().year;
    final lastYear = thisYear - 1;
    return Wrap(
      spacing: 4,
      children: [
        _button(() => selectedDateRange.reset(), 0, 'All time'),
        _button(() => selectedDateRange.lastMonths(3), 1, 'Last 3 months'),
        _button(() => selectedDateRange.year(lastYear), 2, lastYear.toString()),
        _button(() => selectedDateRange.year(thisYear), 3, thisYear.toString()),
        _button(() async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDateRange.range.start,
            firstDate: DateTime(2020, 12),
            lastDate: DateTime.now(),
          );
          if (picked == null || picked == selectedDateRange.range.start)
            return; // no change.
          selectedDateRange.setStart(picked);
        }, 4, 'Set start date'),
      ],
    );
  }

  Widget _button(VoidCallback callback, int idx, String text) {
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
        callback();
      },
      child: Text(text),
    );
  }
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
      label: Text('ALL'),
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

    // TODO(UI): Reduce rounded-rect radius, like in Tagger.
    return FilterChip(
      // This way the chip doesn't ever change size.
      showCheckmark: false,
      selectedColor: category.isIncome ? Colors.green[700] : Colors.red[600],
      label: Text(category),
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
