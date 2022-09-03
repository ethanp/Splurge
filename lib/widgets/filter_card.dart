import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/util/providers.dart';

// TODO(feature): Finish up this filter card.
//
// Plan:
//
// 1) [DONE] Create the filter card.
//
// 2) [DONE] Put the search bar into the Filter Card.
//
// 3) [DONE] Refactor the [TextEditingController] to be an app-level
//    [ValueNotifierProvider] via riverpod.
//
// 4) Put the Category FilterChips into the Filter Card.
//
// 5) Plug all the different cards into the list of txns filtered via the
//    search bar controller. (Available via a riverpod provider.)
//
//    -> Impl note: The Dataset StateNotifier should have the search bar
//    controller run as a pre-filter configured upon it, if you remember what
//    I mean; it's a slightly more advanced usage of the riverpod library.
//    It's very clearly explained in their docs though.
//
// 6) Plug the Category FilterChips into all the different cards too. Ensuring
//    it is INTERSECTION with the SearchBar text filter.
//
class FilterCard extends ConsumerStatefulWidget {
  @override
  FilterCardState createState() => FilterCardState();
}

class FilterCardState extends ConsumerState<FilterCard> {
  late final TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = ref.watch(TextFilter.provider.notifier).controller;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 400,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.brown[900],
        elevation: 4,
        child: _searchBar(),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
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
      ]),
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
}
