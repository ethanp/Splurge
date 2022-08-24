import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splurge/data_model.dart';

final selectedCategoriesProvider =
    StateNotifierProvider<SelectedCategories, Set<String>>(
        (ref) => SelectedCategories());

class SelectedCategories extends StateNotifier<Set<String>> {
  SelectedCategories() : super({});

  bool includes(Transaction txn) =>
      state.isEmpty || state.contains(txn.category);
}
