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
        .updateTo(textEditingController.text));
  }

  @override
  Widget build(BuildContext context) {
    // TODO(UI): Consider using ConstrainedBox or something to let this resize
    //  itself to some extent; since I can't find a single size that looks good
    //  on both laptop and big monitor. Specifically, the card should get taller
    //  as it gets skinnier, to still fit all the chips.
    return SizedBox(
      height: 250,
      width: 500,
      child: Card(
        shape: Shape.roundedRect(circular: 20),
        color: Colors.brown[900],
        elevation: 4,
        child: Column(children: [
          // TODO(feature): Allow filter by date-range. I'm thinking using a
          //  date-picker off-the-shelf, placed to the right of the of the
          //  search bar.
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

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _AllChip(allCategories),
        ...allCategories.map(_CategoryChip.new),
      ],
    );
  }
}

/// Simple way to allow the user to analyze by EXCLUDING categories.
class _AllChip extends ConsumerWidget {
  const _AllChip(this.allCategories);

  final Set<String> allCategories;

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
