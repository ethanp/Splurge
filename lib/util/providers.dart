import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';

final selectedCategoriesProvider =
    StateNotifierProvider<SelectedCategories, Set<String>>(
        (ref) => SelectedCategories());

class SelectedCategories extends StateNotifier<Set<String>> {
  SelectedCategories() : super({});

  bool contains(String category) => state.contains(category);

  bool includes(Transaction txn) =>
      state.isEmpty || state.contains(txn.category);

  void add(String category) => state = {...state, category};

  void remove(String category) => state = {...state..remove(category)};
}
