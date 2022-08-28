import 'package:flutter/material.dart';

class FilterCard extends StatelessWidget {
  FilterCard({Key? key})
      : textEditingController = TextEditingController(),
        super(key: key);

  // TODO: Get this from the correct place.j
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 500, width: 400, child: Card(child: _searchBar()));
  }

  // TODO(feature): Alsot pu the [Category FilterChips] here, and apply them
  //  *across the whole app*; including eg. the line chart, bar charts, and
  //  "txns review" list.
  //
  // Plan:
  //
  // 1) Put the Category FilterChips inside this FilterCard widget too.
  //
  // 2) Refactor the [TextEditingController] to be an app-level
  //    [ValueNotifierProvider] via riverpod.
  //
  //    -> Cleanup: Now we can probably make that one stateful widget stateless.
  //
  // 3) Plug all the different cards into the list of txns filtered via the
  //    search bar controller. (Available via a riverpod provider.)
  //
  //    -> Impl note: The Dataset StateNotifier should have the search bar
  //    controller run as a pre-filter configured upon it, if you remember what
  //    I mean; it's a slightly more advanced usage of the riverpod library.
  //    It's very clearly explained in their docs though.
  //
  // 4) Plug the Category FilterChips into all the different cards too. Ensuring
  //    it is INTERSECTION with the SearchBar text filter.
  //
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Expanded(
          child: TextFormField(
            controller: textEditingController,
            // TODO(UI): Improve this part.
            decoration: InputDecoration(
              hintText: 'Hint text',
              helperText: 'Helper text',
              counterText: 'Counter text',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Icon(Icons.search, color: Colors.lightBlue[200]),
      ]),
    );
  }
}
