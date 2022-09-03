import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return SizedBox(
      height: 200,
      width: 480,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.brown[900],
        elevation: 4,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _clearFieldButton(),
        Expanded(
          child: TextFormField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: 'Matches transactions by title',
              // TODO(UI): Implement real count.
              helperText: '122 matching txns',
              labelText: 'Transaction filter',
              counterText: 'Active iff non-empty',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 20),
          child: Icon(
            Icons.search,
            size: 40,
            color: Colors.lightBlue[200],
          ),
        ),
      ],
    );
  }

  Widget _clearFieldButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 30, right: 12),
      child: IconButton(
        onPressed: () => textEditingController.clear(),
        icon: Icon(Icons.clear, size: 36),
        color: Colors.red,
        hoverColor: Colors.brown[800]!.withOpacity(.5),
      ),
    );
  }

  Widget _categoryChips() {
    ref.watch(SelectedCategories.provider);
    final selectedCategories = ref.read(SelectedCategories.provider.notifier);
    final fullDataset = ref.read(DatasetNotifier.unfilteredProvider);
    final categoryNames =
        fullDataset.transactions.map((txn) => txn.category).toSet();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final categoryName in categoryNames)
          FilterChip(
            showCheckmark: false, // This way the chip doesn't ever change size.
            selectedColor: Colors.orange[900],
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
