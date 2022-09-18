import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';
import 'package:splurge/util/extensions/framework_extensions.dart';
import 'package:splurge/util/providers.dart';

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
    final txns = ref.read(DatasetNotifier.filteredProvider);
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
    ref.watch(SelectedCategories.provider);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);
    final fullDataset = ref.read(DatasetNotifier.unfilteredProvider);
    final categoryNames = fullDataset.txns.map((txn) => txn.category).toSet();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        // TODO(UX): Can we do a right-click to EXCLUDE feature?
        for (final categoryName in categoryNames)
          FilterChip(
            // This way the chip doesn't ever change size.
            showCheckmark: false,
            selectedColor:
                categoryName.isIncome ? Colors.green[700] : Colors.red[600],
            label: Text(categoryName),
            selected: selectedCategories.contains(categoryName),
            onSelected: (bool? isSelected) {
              if (isSelected ?? false)
                selectedCategories.add(categoryName);
              else
                selectedCategories.remove(categoryName);
            },
          ),
      ],
    );
  }
}
